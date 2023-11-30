extends Node2D

@export var player_scene:PackedScene
var initialEquip
var players=[]
var levelStarted=0
var teamCount=0
var playerCounter=0
var teamjoinrequests=[]
var teams=[]
var time=0
var pendingconnections={}

func _ready():
	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(add_peer)
		multiplayer.peer_disconnected.connect(disconnect_player)
		add_player()
	else:
		multiplayer.peer_connected.connect(authenticate_client)
		multiplayer.peer_disconnected.connect(host_disconnected)

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
@rpc("any_peer")
func authenticate(password):
	if !is_multiplayer_authority:
		return
	if levelStarted&&Global.teamAndRespawnDuringGame>=1:
		return
	if password==Global.password:
		var id=multiplayer.get_remote_sender_id()
		if pendingconnections.has(id):
			pendingconnections[id].stop()
			pendingconnections[id].queue_free()
			pendingconnections.erase(id)
			add_player(id)
func kick_player(id):
	multiplayer.disconnect_peer(id)

func add_player(id=1):
	print_debug("New player ",id)
	var player=player_scene.instantiate()
	player.id=id
	player.name=str(playerCounter)
	playerCounter+=1
	player.initPlayer(teamCount)
	teamCount+=1
	teams+=[1]
	player.resetInventory()
	add_child(player)
	players.append(player)
	player.respawn.connect(respawn)
	player.requestjointeamsignal.connect(newteamjoinrequest)
	player.acceptteamrequestsignal.connect(acceptteamrequest)
	player.startgamesignal.connect(toggle_game)
	if levelStarted==1:
		respawn(player)
		player.healthEnabled=true
	elif levelStarted==0&&players.size()==Global.desiredPlayerCount:
		start_game()
	player.setAllowedActions.rpc_id(player.id,Global.chooseTeams,true,false)
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
		var pos=Vector2(randf_range(bounds.position.x,bounds.end.x),randf_range(bounds.position.y,bounds.end.y))
		player.initPlayer(player.team,pos)
		player.healthEnabled=true
		player.show_message(null)
		player.setAllowedActions.rpc_id(player.id,Global.teamAndRespawnDuringGame<1,Global.teamAndRespawnDuringGame<2,true)

func disconnect_player(id):
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
	
func respawn(player):
	if levelStarted==1&&Global.teamAndRespawnDuringGame>=2:
		return
	var bounds=get_node("Area2D/CollisionShape2D").shape.get_rect()		
	var pos=Vector2(randf_range(bounds.position.x,bounds.end.x),randf_range(bounds.position.y,bounds.end.y))
	player.initPlayer(player.team,pos)

func host_disconnected(id):
	if id==1:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
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
	print_debug(1)
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
			print_debug(2)
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
