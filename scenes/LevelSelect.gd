extends Control

var peer = ENetMultiplayerPeer.new();
var host=false
var playerCount=2
var ip="127.0.0.1"
var port=212
var equip=[]
var itemsPath="res://scenes/abilities/"
@export var player_scene:PackedScene

func getItems():
		var files = []
		var dir = DirAccess.open(itemsPath)
		dir.list_dir_begin()

		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif file.ends_with(".tscn") && file!="ability.tscn":
				files.append(file)

		dir.list_dir_end()
		return files

func _ready():
	$LevelConfig.hide()
	$JoinLevelConfig.hide()
	equip.resize(100)
	equip[0]="gun"
	equip[1]="spiral"
	equip[2]="railgun"
	equip[4]="dash"
	equip[10]="regen_2"
	Global.initialEquip=[]
	Global.itemList=[]
	
	var i=0	
	for slot in get_node("LevelConfig/CenterContainer/Inventory/DefaultInventory/GridContainer").get_children():
		if equip[i]!=null:
			equip[i]+=".tscn"
			Global.initialEquip+=[load(itemsPath+equip[i]).instantiate()]
		i+=1
	var itemList=getItems()
	print_debug(equip)
	for item in itemList:
		Global.itemList+=[load(itemsPath+item).instantiate()]
		print_debug(item," ",item in equip)
		if item in equip:
			continue
		Global.initialEquip+=[load(itemsPath+item).instantiate()]

func _on_h_slider_value_changed(value):
	playerCount=value
	get_node("LevelConfig/VBoxContainer/SpinBox").value=value


func _on_spin_box_value_changed(value):
	playerCount=value
	get_node("LevelConfig/VBoxContainer/HSlider").value=value

func _on_host_pressed():
	$LevelConfig.show()
	$LevelList.hide()
	host=true
	
	
func _on_join_pressed():
	$JoinLevelConfig.show()
	$LevelList.hide()
	host=false



func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Level.tscn")
	if host:
		Global.desiredPlayerCount=playerCount
		peer.create_server(port)
	else:
		peer.create_client(ip,port)
	multiplayer.multiplayer_peer=peer


func _on_port_value_changed(value):
	port=value
	get_node("LevelConfig/VBoxContainer/Port").value=value
	get_node("JoinLevelConfig/VBoxContainer/Port/SpinBox2").value=value


func _on_join_ip_changed(new_text):
	ip=new_text


func _on_back_button_pressed():
	$LevelConfig.hide()
	$JoinLevelConfig.hide()
	$LevelList.show()
