extends Level_Base
class_name xx

@export var player_scene: PackedScene
var initialEquip
var players = []
var teamCount = 0
var playerCounter = 0
var teamjoinrequests = []
var teams = []
var teamAlivePlayerCount = []
var scores=[]


func _ready():
	if is_multiplayer_authority():
		multiplayer.peer_disconnected.connect(remove_player)
		if Global.teamSizeRule == 1:
			teams.resize(Global.teamSize)
			teams.fill(0)
			teamAlivePlayerCount.resize(Global.teamSize)
			teamAlivePlayerCount.fill(0)
			teamCount = Global.teamSize
		add_player()
		Global.spawnObject.connect(spawnObject)
		Global.onKill.connect(handleKill)
	else:
		multiplayer.peer_disconnected.connect(host_disconnected)


func spawnObject(x: Node):
	add_child.call_deferred(x)


func add_player(id:int = 1):
	print_debug("New player ", id)
	var player = player_scene.instantiate()
	player.id = id
	player.name = str(playerCounter)
	playerCounter += 1
	player.initPlayer()
	var t = teamCount
	if Global.assignTeams || Global.teamSizeRule == 1:
		t = 0
		for i in range(teamCount):
			if teams[i] < teams[t]:
				t = i
		if teamCount == 0 || Global.teamSizeRule == 0 && teams[t] >= Global.teamSize:
			t = teamCount
	addPlayerToTeam(player, t)
	player.resetInventory()
	spawnObject(player)
	players.append(player)
	player.respawn.connect(respawn)
	player.deathSignal.connect(playerDead)
	player.requestjointeamsignal.connect(newteamjoinrequest)
	player.acceptteamrequestsignal.connect(acceptteamrequest)
	player.startgamesignal.connect(toggle_game)
	player.setAllowedActions.rpc_id(player.id, Global.chooseTeams, true, false)
	if levelStarted == 1:
		setPlayerLocation(player)
		player.healthEnabled = true
		player.setAllowedActions.rpc_id(
			player.id,
			Global.teamAndRespawnDuringGame < 1,
			Global.teamAndRespawnDuringGame < 2,
			true
		)
	elif levelStarted == 0 && players.size() == Global.desiredPlayerCount:
		start_game()


func toggle_game():
	if levelStarted == 1:
		end_game()
	elif levelStarted == 0:
		start_game()


func start_game():
	levelStarted = 2
	for p in players:
		p.show_message("Level Starting")
	var timer = Timer.new()
	timer.connect("timeout", start_game2)
	timer.set_one_shot(true)
	timer.set_wait_time(3)  #value is in seconds: 600 seconds = 10 minutes
	add_child(timer)
	timer.start()


func start_game2():
	levelStarted = 1
	scores=[]
	for player in players:
		player.healthEnabled = true
		player.show_message(null)
		player.setAllowedActions.rpc_id(
			player.id,
			Global.teamAndRespawnDuringGame < 1,
			Global.teamAndRespawnDuringGame < 2,
			true
		)
		player.score=1
		setPlayerLocation(player)
	updateScores()


func end_game():
	
	levelStarted = 0
	for player in players:
		player.healthEnabled = false
		player.show_message("Game Over")
		player.setAllowedActions.rpc_id(player.id, Global.chooseTeams, true, false)


func remove_player(id):
	for player in players:
		if player.id == id:
			var timer = Timer.new()
			timer.timeout.connect(del_player.bind(player))
			timer.set_one_shot(true)
			timer.set_wait_time(60)
			add_child(timer)
			timer.start()


func del_player(player):
	rpc("del_player_client", player.name)
	players.erase(player)


@rpc("authority", "call_local")
func del_player_client(name):
	get_node(str(name)).queue_free()


func respawn(player, check = true):
	if check && levelStarted == 1 && Global.teamAndRespawnDuringGame >= 2:
		return
	player.score=1
	player.initPlayer()
	setPlayerLocation(player)
	teamAlivePlayerCount[player.team] += 1
func setPlayerLocation(player):
	var bounds = get_node("Area2D/CollisionShape2D").shape.get_rect()
	var pos = Vector2(
		randf_range(bounds.position.x, bounds.end.x), randf_range(bounds.position.y, bounds.end.y)
	)
	player.position=pos


func playerDead(player):
	teamAlivePlayerCount[player.team] -= 1
	var aliveTeamCount = 0
	for team in teamAlivePlayerCount:
		if team > 0:
			aliveTeamCount += 1
	if aliveTeamCount <= 1:
		end_game()


func host_disconnected(id):
	if id == 1:
		Global.changeLevel.emit("main_menu")
		return


func _on_area_2d_area_exited(area):
	if !is_multiplayer_authority():
		return
	if area.get_groups().has("player"):
		var bounds = get_node("Area2D/CollisionShape2D").shape.get_rect()
		var newPos = area.position.clamp(bounds.position, bounds.end)
		var dir = (area.position - newPos).normalized()
		area.velocity -= area.velocity.dot(dir) * dir * 2
		area.position = newPos


func playerFromId(id: int):
	for player in players:
		if player.id == id:
			return player
	return null


func playerFromName(name: String):
	for player in players:
		if player.name == name:
			return player
	return null


func switchPlayerToTeam(player, team):
	teams[player.team] -= 1
	teamAlivePlayerCount[team] -= int(!player.spectator)
	addPlayerToTeam(player, team)


func addPlayerToTeam(player, team):
	if team >= teamCount:
		team = teamCount
		teamCount += 1
		teams += [0]
		teamAlivePlayerCount += [0]
	player.team = team
	teams[team] += 1
	teamAlivePlayerCount[team] += int(!player.spectator)


func newteamjoinrequest(a, b):
	if levelStarted == 1 && Global.teamAndRespawnDuringGame >= 1 || !Global.chooseTeams:
		return
	var player = playerFromId(a)
	if !player:
		return
	if Global.teamSizeRule == 1:
		if b in range(teamCount):
			switchPlayerToTeam(player, b)
		return
	if player.name == b:
		switchPlayerToTeam(player, teamCount)
		return
	var player2 = playerFromName(b)
	if player2:
		if teams[player2.team] >= Global.teamSize:
			return
		var c = false
		for x in teamjoinrequests:  #ignore if same request was made in last 10 seconds
			if x[0] == a && x[1] == b:
				if x[2] > Global.time- 10:
					return
				x[2] = Global.time
				c = true
		if !c:
			teamjoinrequests += [[a, b, Global.time]]
		player2.showteamrequest.rpc_id(player2.id, a, player.name)


func acceptteamrequest(a, b):
	for x in teamjoinrequests:
		if x[0] == a && x[1] == b && x[2] > Global.time- 10:
			var player1 = playerFromId(a)
			var player2 = playerFromName(b)
			if player1 && player2:
				switchPlayerToTeam(player1, player2.team)
			return

func handleKill(killer:Node,killed:Node):
	killer.score+=killed.score
	killed.score=0
	var x=null
	for score in scores:
		if score[1]==killed.name:
			x=score
	scores.erase(x)
	x=false
	for score in scores:
		if score[1]==killer.name:
			score[0]=killer.score
			x=true
	if !x:
		scores+=[[killer.score,killer.name,killer.username if "username" in killer else ""]]
	scores.sort()
	scores.reverse()
	updateScores()
func updateScores():
	for player in players:
		player.updateScoreboard.rpc_id(player.id,scores)
