extends Level
var character7=load("res://scenes/projectiles/characters/Character7.tscn")
var character9=load("res://scenes/projectiles/characters/Character9.tscn")
var character10=load("res://scenes/projectiles/characters/Character10.tscn")
var character7b=load("res://scenes/projectiles/characters/Character7b.tscn")
var character9a=load("res://scenes/projectiles/characters/Character9a.tscn")
var character11=load("res://scenes/projectiles/characters/Character11.tscn")
var enemySpawnPoints: Array[Node]
var waveCount=1
var waveSize:Array[int]=[1,5,2,1]
var waveEnemies=[[character11],[character9],[character10],[character7b]]
var waveSpawnRates:Array[float]=[1,3,5,1]
var waveRestTime:float=10
var waveProgress:int
var waveSpawnComplete:bool
var wave:int


func _ready():
	super()
	enemySpawnPoints=$Spawnpoints.get_children()
	startingScore=0

func add_player(id: int = 1):
	super(id)
	setPlayerLocation(players[-1])

func start_game2():
	super()
	wave=0
	startWave()

func startWave():
	print_debug(wave)
	if wave==waveCount:
		end_game()
		return
	waveSpawnComplete=false
	for i in range(waveSize[wave]):
		var enemy=waveEnemies[wave].pick_random()
		spawnEnemy(enemy)
		$Timer.start(waveSpawnRates[wave])
		await $Timer.timeout
	waveSpawnComplete=true

func handleKill(killer:Node,killed:Node):
	super(killer,killed)
	if killer.get_groups().has("player")&&killed.get_groups().has("character"):
		waveProgress+=1
	var characters=get_tree().get_nodes_in_group("character")
	var waveComplete=true
	for character in characters:
		if character.health>0&&!character.get_groups().has("player"):
			waveComplete=false
			break
	if waveComplete&&waveSpawnComplete:
		waveProgress=0
		wave+=1
		$Timer.start(waveRestTime)
		await $Timer.timeout
		startWave()

func setPlayerLocation(player:Player):
	player.position = Vector2.ZERO

func checkGameOver():
	var aliveTeamCount = 0
	for i in range(teamCount):
		if teamAlivePlayerCount[i] > 0:
			aliveTeamCount += 1
	if aliveTeamCount <= 0:
		end_game()

var x=0
func spawnEnemy(enemy:PackedScene):
	var e=enemy.instantiate()
	var pos=enemySpawnPoints.pick_random().position
	e.init2(pos,9999)
	e.targetDistance=1e4
	e.untargetDistance=1e4
	e.score=1
	x+=1
	e.name+=str(x)
	
	spawnObject(e)






func _on_timer_timeout():
	pass # Replace with function body.
