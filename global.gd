extends Node

var desiredPlayerCount=2
var teamSize=1
var teamSizeRule=0
var initialEquip
var itemList=[]
var username=""
var chooseTeams=true
var assignTeams=false
var teamAndRespawnDuringGame=0
var password=""
const VIEWPORT_SIZE=Vector2(2560,1440)
var time=0

var level
signal spawnObject(x:Node)
signal changeLevel(level)
signal onKill(killer:Node,killed:Node)

var pendingconnections={}

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
	changeLevel.emit()
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
