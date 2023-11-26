extends Node2D

@export var player_scene:PackedScene
@onready var cam=$Camera2D;
var peer = ENetMultiplayerPeer.new();
var initialEquip
var players=[]
var levelStarted=false

func _ready():
	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(add_player)
		add_player()


func add_player(id=1):
	print_debug("New player ",id)
	var player=player_scene.instantiate()
	player.name=str(id)
	player.initPlayer(id)
	player.resetInventory()
	add_child(player)
	players.append(player)
	player.quit.connect(exit_game)
	player.respawn.connect(respawn)
	if levelStarted:
		var bounds=get_node("Area2D/CollisionShape2D").shape.get_rect()		
		var pos=Vector2(randf_range(bounds.position.x,bounds.end.x),randf_range(bounds.position.y,bounds.end.y))
		player.initPlayer(player.name.to_int(),pos)
		player.healthEnabled=true
	elif players.size()==Global.desiredPlayerCount:
		levelStarted=true
		for p in players:
			p.show_message("Level Starting")
		var timer = Timer.new()
		timer.connect("timeout",start_game) 
		timer.set_one_shot(true)
		timer.set_wait_time(1) #value is in seconds: 600 seconds = 10 minutes
		add_child(timer) 
		timer.start() 

func start_game():
	var bounds=get_node("Area2D/CollisionShape2D").shape.get_rect()
	for player in players:
		var pos=Vector2(randf_range(bounds.position.x,bounds.end.x),randf_range(bounds.position.y,bounds.end.y))
		player.initPlayer(player.name.to_int(),pos)
		player.healthEnabled=true
		player.show_message(null)

func exit_game(id):
	#multiplayer.peer_disconnected.connect(del_player)
	print_debug(id)
	rpc("_del_player",id)

@rpc("authority","call_local") func _del_player(id):
	get_node(str(id)).queue_free()
	
func respawn(id):
	print_debug(id)


func _on_area_2d_area_exited(area):
	if !is_multiplayer_authority():
		return
	if area.get_groups().has("player"):
		var bounds=get_node("Area2D/CollisionShape2D").shape.get_rect()
		var newPos=area.position.clamp(bounds.position,bounds.end)
		var dir=(area.position-newPos).normalized()
		area.velocity-=area.velocity.dot(dir)*dir
		area.position=newPos
