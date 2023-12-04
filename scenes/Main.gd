extends Node
var level
var pendingconnections={}
func _ready():
	level=$MainMenu
	level.changeLevel.connect(changeLevel)
	level.startMultiplayer.connect(startMultiplayer)

func changeLevel(newLevel=null):
	if level:
		level.queue_free()
	if newLevel:
		var x=newLevel
		newLevel=load("res://scenes/levels/"+newLevel+".tscn").instantiate()
		level=newLevel
		add_child(newLevel)
		level.changeLevel.connect(changeLevel)
		level.startMultiplayer.connect(startMultiplayer)
	else:
		level=null

func startMultiplayer():
	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(add_peer)
	else:
		multiplayer.peer_connected.connect(authenticate_client)
func add_peer(id):
	var timer = Timer.new()
	timer.connect("timeout",kick_player.bind(id)) 
	timer.set_one_shot(true)
	timer.set_wait_time(1) #value is in seconds: 600 seconds = 10 minutes
	add_child(timer) 
	timer.start() 
	pendingconnections[id]=timer
func authenticate_client(id):
	if id==1:
		authenticate.rpc_id(1,Global.password)
@rpc("any_peer") func authenticate(password):
	if !is_multiplayer_authority:
		return
	if level.levelStarted&&Global.teamAndRespawnDuringGame>=1:
		return
	if password==Global.password:
		var id=multiplayer.get_remote_sender_id()
		if pendingconnections.has(id):
			pendingconnections[id].stop()
			pendingconnections[id].queue_free()
			pendingconnections.erase(id)
			level.add_player(id)

func kick_player(id):
	multiplayer.disconnect_peer(id)


