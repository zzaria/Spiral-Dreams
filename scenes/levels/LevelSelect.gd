extends Level_Base

var peer
var host=false
var ip="127.0.0.1":
	set(x):
		get_node("JoinLevelConfig/VBoxContainer/Ip/LineEdit").text=x
var port=212:
	set(x):
		get_node("LevelConfig/HBoxContainer/VBoxContainer/Port").value=x
		get_node("JoinLevelConfig/VBoxContainer/Port/SpinBox2").value=x
var equip=[]
var itemsPath="res://scenes/abilities/"
var desiredPlayerCount=2:
	set(x):
		Global.desiredPlayerCount=x
		get_node("LevelConfig/HBoxContainer/VBoxContainer/HSlider").value=x
		get_node("LevelConfig/HBoxContainer/VBoxContainer/SpinBox").value=x
var teamAndRespawnDuringGame=0:
	set(x):
		get_node("LevelConfig/HBoxContainer/VBoxContainer/ItemList2").select(x,true)
		Global.teamAndRespawnDuringGame=x
var password="":
	set(x):
		Global.password=x
		get_node("LevelConfig/HBoxContainer/VBoxContainer/LineEdit").text=x
		get_node("JoinLevelConfig/VBoxContainer/Password/LineEdit").text=x
var teamSizeRule=0:
	set(x):
		Global.teamSizeRule=x
		get_node("LevelConfig/HBoxContainer/VBoxContainer2/ItemList4").select(x,true)
var teamSize=1:
	set(x):
		Global.teamSize=x
		get_node("LevelConfig/HBoxContainer/VBoxContainer2/SpinBox2").value=x
var chooseTeams=false:
	set(x):
		Global.chooseTeams=x
		get_node("LevelConfig/HBoxContainer/VBoxContainer2/HBoxContainer/CheckBox").button_pressed=x
var assignTeams=false:
	set(x):
		Global.assignTeams=x
		get_node("LevelConfig/HBoxContainer/VBoxContainer2/HBoxContainer2/CheckBox").button_pressed=x
var level=0:
	set(x):
		level=x
		get_node("LevelConfig/HBoxContainer/VBoxContainer2/ItemList5").select(x,true)
var username="":
	set(x):
		Global.username=x
		get_node("LevelList/LevelType/Username").text=x

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
	ip=ip
	port=port
	desiredPlayerCount=desiredPlayerCount
	teamAndRespawnDuringGame=teamAndRespawnDuringGame
	password=password
	teamSizeRule=teamSizeRule
	teamSize=teamSize
	chooseTeams=chooseTeams
	assignTeams=assignTeams
	level=level
	username=username
	
	var i=0	
	for slot in get_node("LevelConfig/CenterContainer/Inventory/DefaultInventory/GridContainer").get_children():
		if equip[i]!=null:
			equip[i]+=".tscn"
			Global.initialEquip+=[load(itemsPath+equip[i]).instantiate()]
		i+=1
	var itemList=getItems()
	for item in itemList:
		Global.itemList+=[load(itemsPath+item).instantiate()]
		if item in equip:
			continue
		Global.initialEquip+=[load(itemsPath+item).instantiate()]

func _on_host_pressed():
	$LevelConfig.show()
	$LevelList.hide()
	host=true
	
	
func _on_join_pressed():
	$JoinLevelConfig.show()
	$LevelList.hide()
	host=false



func _on_start_button_pressed():
	peer=ENetMultiplayerPeer.new()
	var e
	if host:
		e=peer.create_server(port)
	else:
		e=peer.create_client(ip,port)
	if e!=OK:
		return
	multiplayer.multiplayer_peer=peer
	Global.startMultiplayer()
	if host:
		Global.changeLevel.emit("Level"+str(level))
	
	


func _on_h_slider_value_changed(value):
	Global.desiredPlayerCount=value


func _on_spin_box_value_changed(value):
	Global.desiredPlayerCount=value

func _on_port_value_changed(value):
	port=value


func _on_join_ip_changed(new_text):
	ip=new_text


func _on_back_button_pressed():
	$LevelConfig.hide()
	$JoinLevelConfig.hide()
	$LevelList.show()


func _on_spin_box_2_value_changed(value):
	Global.teamSize=value
	


func _on_username_text_changed(new_text):
	username=new_text

func _on_item_list_2_item_selected(index):
	teamAndRespawnDuringGame=index


func _on_line_edit_text_changed(new_text):
	password=new_text



func _on_item_list_4_item_selected(index):
	teamSizeRule=index


func _on_item_list_5_item_selected(index):
	level=index


func _on_check_box2_toggled(button_pressed):
	chooseTeams=button_pressed


func _on_check_box_toggled(button_pressed):
	assignTeams=button_pressed


func _on_leveltype_back_button_pressed():
	Global.changeLevel.emit("main_menu")
