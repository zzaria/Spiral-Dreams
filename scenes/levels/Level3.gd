extends xx

var teamSpawnScene = preload("res://scenes/projectiles/characters/TeamSpawn.tscn")
var spawners = []
var spawns
const TEAMS = 2
var canRespawn = []


# Called when the node enters the scene tree for the first time.
func _ready():
	if is_multiplayer_authority():
		Global.teamSizeRule = 1
		Global.teamSize = TEAMS
		Global.teamAndRespawnDuringGame = 1
		spawns = [$Spawn1.position, $Spawn2.position]
		canRespawn.resize(TEAMS)
		canRespawn.fill(true)
		for i in range(TEAMS):
			spawners += [teamSpawnScene.instantiate()]
			spawners[i].position = spawns[i]
			spawners[i].team = i
			spawners[i].name = "Spawner" + str(i)
			spawnObject(spawners[i])
			spawners[i].dead.connect(spawnerDead)
	super()


func add_player(id: int = 1):
	super(id)
	setPlayerLocation(players[-1])


func setPlayerLocation(player):
	player.position = spawns[player.team]


func start_game2():
	for spawner in spawners:
		spawner.healthEnabled = true
	levelStarted = 1
	scores = []
	for player in players:
		player.healthEnabled = true
		player.show_message(null)
		player.setAllowedActions.rpc_id(
			player.id,
			Global.teamAndRespawnDuringGame < 1,
			Global.teamAndRespawnDuringGame < 2,
			true
		)
		player.score = 0
		setPlayerLocation(player)
	updateScores


func end_game():
	canRespawn.fill(true)
	super()


func spawnerDead(team):
	canRespawn[team] = false
	for player in players:
		if player.team == team:
			player.setAllowedActions.rpc_id(player.id, false, false, true)
	checkGameOver()


func respawn(player, check = true):
	if canRespawn[player.team]:
		player.initPlayer()
		setPlayerLocation(player)
		teamAlivePlayerCount[player.team] += 1


func playerDead(player):
	teamAlivePlayerCount[player.team] -= 1
	checkGameOver()


func checkGameOver():
	var aliveTeamCount = 0
	for i in range(teamCount):
		if teamAlivePlayerCount[i] > 0 || canRespawn[i]:
			aliveTeamCount += 1
	if aliveTeamCount <= 1:
		end_game()


func handleKill(killer: Node, killed: Node):
	killer.score += 50 if killed is TeamSpawn else 10 if !canRespawn[killed.team] else 1
	var x = false
	for score in scores:
		if score[1] == killer.name:
			score[0] = killer.score
			x = true
	if !x:
		scores += [[killer.score, killer.name, killer.username if "username" in killer else ""]]
	scores.sort()
	scores.reverse()
	updateScores()
