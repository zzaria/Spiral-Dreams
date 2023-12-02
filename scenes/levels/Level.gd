extends Level_Base

@export var player_scene:PackedScene
var initialEquip
var players=[]
var levelStarted=0
var teamCount=0
var playerCounter=0
var teamjoinrequests=[]
var teams=[]
var time=0

func _ready():
	if is_multiplayer_authority():
		multiplayer.peer_disconnected.connect(remove_player)
		if Global.teamSizeRule==1:
			for i in range(Global.teamSize):
				teams+=[0]
			teamCount=Global.teamSize
		add_player()
	else:
		multiplayer.peer_disconnected.connect(host_disconnected)

func add_player(id=1):
	print_debug("New player ",id)
	var player=player_scene.instantiate()
	player.id=id
	player.name=str(playerCounter)
	playerCounter+=1
	var t=teamCount
	if Global.assignTeams||Global.teamSizeRule==1:
		t=0
		for i in range(teamCount):
			if teams[i]<teams[t]:
				t=i
		if teamCount==0||Global.teamSizeRule==0&&teams[t]>=Global.teamSize:
			t=teamCount
	if t==teamCount:
		teams+=[0]
		teamCount+=1
	player.initPlayer(t)
	teams[t]+=1
	player.resetInventory()
	add_child(player)
	players.append(player)
	player.respawn.connect(respawn)
	player.requestjointeamsignal.connect(newteamjoinrequest)
	player.acceptteamrequestsignal.connect(acceptteamrequest)
	player.startgamesignal.connect(toggle_game)
	player.setAllowedActions.rpc_id(player.id,Global.chooseTeams,true,false)
	if levelStarted==1:
		respawn(player,false)
		player.healthEnabled=true
		player.setAllowedActions.rpc_id(player.id,Global.teamAndRespawnDuringGame<1,Global.teamAndRespawnDuringGame<2,true)
	elif levelStarted==0&&players.size()==Global.desiredPlayerCount:
		start_game()
func toggle_game():
	if levelStarted==1:
		end_game()
	elif levelStarted==0:
		start_game()
func end_game():
	pass
func start_game():
	levelStarted=2
	for p in players:
		p.show_message("Level Starting")
	var timer = Timer.new()
	timer.connect("timeout",start_game2) 
	timer.set_one_shot(true)
	timer.set_wait_time(1) #value is in seconds: 600 seconds = 10 minutes
	add_child(timer) 
	timer.start() 

func start_game2():
	levelStarted=1
	var bounds=get_node("Area2D/CollisionShape2D").shape.get_rect()
	for player in players:
		player.healthEnabled=true
		player.show_message(null)
		player.setAllowedActions.rpc_id(player.id,Global.teamAndRespawnDuringGame<1,Global.teamAndRespawnDuringGame<2,true)
		respawn(player,false)

func remove_player(id):
	for player in players:
		if player.id==id:
			var timer=Timer.new()
			timer.timeout.connect(del_player.bind(player)) 
			timer.set_one_shot(true)
			timer.set_wait_time(60)
			add_child(timer)
			timer.start()
	



func del_player(player):
	rpc("del_player_client",player.name)
	players.erase(player)

@rpc("authority","call_local") func del_player_client(name):
	get_node(str(name)).queue_free()
	
func respawn(player,check=true):
	if check&&levelStarted==1&&Global.teamAndRespawnDuringGame>=2:
		return
	var bounds=get_node("Area2D/CollisionShape2D").shape.get_rect()		
	var pos=Vector2(randf_range(bounds.position.x,bounds.end.x),randf_range(bounds.position.y,bounds.end.y))
	player.initPlayer(player.team,pos)

func host_disconnected(id):
	if id==1:
		changeLevel.emit("main_menu")
		return

func _on_area_2d_area_exited(area):
	if !is_multiplayer_authority():
		return
	if area.get_groups().has("player"):
		var bounds=get_node("Area2D/CollisionShape2D").shape.get_rect()
		var newPos=area.position.clamp(bounds.position,bounds.end)
		var dir=(area.position-newPos).normalized()
		area.velocity-=area.velocity.dot(dir)*dir*2
		area.position=newPos
func newteamjoinrequest(a,b):
	if levelStarted==1&&Global.teamAndRespawnDuringGame>=1||!Global.chooseTeams:
		return
	if Global.teamSizeRule==1:
		if b in range(teamCount):
			teams[b]+=1
			for player in players:
				if player.id==a:
					player.team=b
			return
	if a==b:
		for player in players:
			if player.id==a:
				player.team=teamCount
				teamCount+=1
				teams+=[1]
				break

	var name=null
	for player in players:
		if player.id==a:
			name=player.username
			break
	if name==null:
		return
	for player in players:
		if player.id==b:
			if teams[player.team]>=Global.teamSize:
				return
			var c=false
			for x in teamjoinrequests:
				if x[0]==a&&x[1]==b:
					if x[2]>time-10:
						return
					x[2]=time
					c=true
			if !c:
				teamjoinrequests+=[[a,b,time]]
			player.showteamrequest.rpc_id(player.id,a,name)
			break
func acceptteamrequest(a,b):
	for x in teamjoinrequests:
		if x[0]==a&&x[1]==b&&x[2]>time-10:
			var team=null
			for player in players:
				if player.id==b:
					team=player.team
					break
			if team!=null:
				for player in players:
					if player.id==a:
						teams[player.team]-=1
						player.team=team
						teams[player.team]+=1
						break
			break

func _physics_process(delta):
	time+=delta
