class_name Player
extends Projectile
signal respawn
signal quit

var cam
var inventory
var items
var itemDisabled
var healthBar
var energyBar
var scoreDisplay
var messageBox
var message

@export var maxImmunity =0
@export var baseMaxEnergy=1000
@export var maxEnergy=0
@export var energy=0
@export var inventorySize=50
@export var score=1
var globalAttackCooldown=0
var energyTick=0
var timeSinceHit=0
var healthEnabled=false
@export var spectator=false
@export var id=-1

func initPlayer(_team,spawnPoint=Vector2.ZERO):
	team=_team
	health=maxHealth
	energy=baseMaxEnergy
	velocity=Vector2.ZERO
	position=spawnPoint
	spectator=false
	score=1
	owner2=self
	$CollisionShape2D.disabled=false
func setItem(index,item):
	if index>=inventorySize:
		return
	items[index]=item
	if item!=null:
		item.bearer=self
	rpc_id(id,"setItem_client",index,null if item==null else item.name)
@rpc("authority", "call_local", "reliable")
func setItem_client(index,item):
	var slots=get_node("CanvasLayer/Inventory/GridContainer").get_children()
	if not slots:
		return
	slots[index].setItem(item)
var curDragItem
func inventoryDrag(index):
	curDragItem=index
func inventoryDrop(index):
	rpc_id(1,"inventorySwap",curDragItem,index)
	curDragItem=null
@rpc("any_peer", "call_local")
func inventorySwap(x,y):
	if !is_multiplayer_authority()||y==null||x==null||0>x||x>=inventorySize||0>y||y>=inventorySize:
		return
	var ix=items[x]
	var iy=items[y]
	setItem(y,ix)
	setItem(x,iy)
func inventorySlotRightClick_client(index):
	rpc_id(1,"inventorySlotRightClick",index)
@rpc("any_peer", "call_local","reliable")
func inventorySlotRightClick(index):
	if 0<=index&&index<inventorySize:
		itemDisabled[index]=!itemDisabled[index]


	
func resetInventory():
	items=[]
	itemDisabled=[]
	for i in range(0,inventorySize):
		items+=[null]
		itemDisabled+=[false]
	var slots=get_node("CanvasLayer/Inventory/GridContainer").get_children()
	var i=0
	for item in Global.initialEquip:
		setItem(i,item.duplicate())
		i+=1
# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	initPlayer(id)
	
	cam=$Camera2D
	cam.enabled=multiplayer.get_unique_id()==id
	$CanvasLayer.visible=multiplayer.get_unique_id()==id
	inventory=get_node("CanvasLayer/Inventory")
	inventory.itemOwner=self
	inventory.hide()
	
	healthBar=get_node("CanvasLayer/HealthBar")
	energyBar=get_node("CanvasLayer/EnergyBar")
	scoreDisplay=get_node("CanvasLayer/ScoreDisplay")
	messageBox=get_node("CanvasLayer/MessageBox")
	message=get_node("CanvasLayer/MessageBox/CenterContainer/Panel/PanelContainer/Label")
	var slots=get_node("CanvasLayer/Inventory/GridContainer").get_children()
	var i=0
	for slot in slots:
		slot.index=i
		slot.dragSignal.connect(inventoryDrag)
		slot.dropSignal.connect(inventoryDrop)
		slot.rightClickSignal.connect(inventorySlotRightClick_client)
		i+=1
	if is_multiplayer_authority():
		var timer = Timer.new()
		timer.connect("timeout",afsdlknj) 
		timer.set_one_shot(true)
		timer.set_wait_time(1)
		add_child(timer) 
		timer.start() 
func afsdlknj():
	var i=0
	for item in items:
		if item!=null:
			rpc_id(id,"setItem_client",i,item.name)
		i+=1

func _enter_tree():
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	if spectator&&multiplayer.get_unique_id()!=id:
		self.hide()
	else:
		self.show()

	if velocity.length()>0.01:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	if abs(velocity.x) > abs(velocity.y):
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0
	
	healthBar.max_value=maxHealth
	healthBar.value=health
	healthBar.get_node("Label").text="Health: "+str(round(health))
	energyBar.max_value=maxEnergy
	energyBar.value=energy
	energyBar.get_node("Label").text="Energy: "+str(round(energy))
	scoreDisplay.get_node("Label").text="Score: "+str(round(score))

	if multiplayer.get_unique_id()!=id:
		return
	doAbilities()
	doMovement(delta)
		
func _physics_process2(delta):
	var i=0
	for item in items:
		if item!=null&&!itemDisabled[i]:
			item.updateTimer(delta)
			item.tryEffect()
		i+=1
	timeSinceHit+=delta
	
	energyTick+=delta
	if globalAttackCooldown>=-2:
		globalAttackCooldown-=delta
	while energyTick>0:
		var secondsTofull=3
		var energyTickDelay=0.1
		var rate=0.5*energyTickDelay/secondsTofull
		if energy<maxEnergy*0.5:
			energy+=maxEnergy*rate
		else:
			rate/=5
			energy=max(energy,energy*(1-2*rate)+maxEnergy*2*rate)
		energyTick-=energyTickDelay
		

func resetStats():
	super.resetStats()
	maxEnergy=baseMaxEnergy

func doAbilities():
	var useSlots=[]
	var toggleSlots=[]
	for i in range(1,6):
		if Input.is_action_pressed("use"+str(i)):
			useSlots.append(i-1)
		if Input.is_action_pressed("toggle"+str(i)):
			toggleSlots.append(i-1)
	if len(useSlots)>0 || len(toggleSlots)>0:
		rpc_id(1,"doAbilitiesServer",get_local_mouse_position(),useSlots,toggleSlots)

@rpc("any_peer", "call_local") func doAbilitiesServer(mousePos,useSlots,toggleSlots):
	if id!=multiplayer.get_remote_sender_id():
		return
	if !is_multiplayer_authority():
		return
	for i in toggleSlots:
		if items[i]!=null:
			items[i].toggle()
	for i in useSlots:
		if items[i]!=null&&!itemDisabled[i]:
			items[i].attemptAbility(mousePos)
	var i=0
	for item in items:
		if item!=null&&item.autofire&&!itemDisabled[i]:
			item.attemptAbility(mousePos)
		i+=1

func doMovement(delta):
	rpc_id(1,"doMovementServer",delta,Input.get_vector("move_left","move_right","move_up","move_down"))

@rpc("any_peer", "call_local") func doMovementServer(delta,inputDir):
	if id!=multiplayer.get_remote_sender_id():
		return
	if !is_multiplayer_authority():
		return
	accelerationDir=inputDir
	
	if accelerationDir.length()>0:
		accelerationDir=accelerationDir.normalized()


func _input(event):
	if multiplayer.get_unique_id()!=id:
		return
	if event.is_action_pressed("inventory"):
		inventory.visible=!inventory.visible
		
func _on_area_entered(area):
	super._on_area_entered(area)
func takeDamage(d,source=null):
	if !healthEnabled:
		return
	if timeSinceHit<maxImmunity:
		return
	super.takeDamage(d)
	timeSinceHit=0
	if health<0&&!spectator:
		if source!=null:
			source.onKill(self)
		score=0
		die()
func onKill(victim):
	score+=victim.score
	energy+=maxEnergy/2
	health+=maxHealth/6
	
func die():
	spectator=true
	$CollisionShape2D.disabled=true
	rpc_id(id,"die_client")
@rpc("authority", "call_local", "reliable")
func die_client():
	get_node("CanvasLayer/DeathScreen").show()

func show_message(text):
	rpc_id(id,"show_message_client",text)

@rpc("authority", "call_local", "reliable")
func show_message_client(text):
	if text==null:
		messageBox.hide()
	else:
		message.text=text
		messageBox.show()

func _on_respawn_pressed():
	rpc_id(1,"_on_respawn_pressed_server")
	get_node("CanvasLayer/DeathScreen").hide()
	
@rpc("any_peer", "call_local") func _on_respawn_pressed_server():
	if id!=multiplayer.get_remote_sender_id() || !is_multiplayer_authority():
		return
	respawn.emit(self)

func _on_quit_pressed():
	#rpc_id(1,"_on_quit_pressed_server")
	multiplayer.multiplayer_peer=null
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

@rpc("any_peer", "call_local") func _on_quit_pressed_server():
	pass
	if multiplayer.get_remote_sender_id()!=id || !is_multiplayer_authority():
		return
	quit.emit(id)
	
func server_disconnected(): #doesn't work
	pass
