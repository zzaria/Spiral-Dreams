class_name Player
extends Projectile
signal respawn
signal quit

var cam
var inventory
var items
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
var energyTick=0
var timeSinceHit=0
var healthEnabled=false
var spectator=false

func initPlayer(_team,spawnPoint=Vector2.ZERO):
	team=_team
	health=maxHealth
	energy=baseMaxEnergy
	velocity=Vector2.ZERO
	position=spawnPoint
	incomingDamage=0
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
	rpc_id(name.to_int(),"setItem_client",index,null if item==null else item.name)
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
	if items[index]!=null:
		items[index].disabled=!items[index].disabled


	
func resetInventory():
	items=[]
	for i in range(0,inventorySize):
		items+=[null]
	var slots=get_node("CanvasLayer/Inventory/GridContainer").get_children()
	var i=0
	for item in Global.initialEquip:
		setItem(i,item.duplicate())
		i+=1
# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	initPlayer(name.to_int())
	
	cam=$Camera2D
	cam.enabled=multiplayer.get_unique_id()==name.to_int()
	$CanvasLayer.visible=multiplayer.get_unique_id()==name.to_int()
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
			rpc_id(name.to_int(),"setItem_client",i,item.name)
		i+=1

func _enter_tree():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
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

	if multiplayer.get_unique_id()!=name.to_int():
		return
	doAbilities()
	doMovement(delta)
		
func _physics_process2(delta):
	for item in items:
		if item!=null:
			item.updateTimer(delta)
			item.tryEffect()
	timeSinceHit+=delta
	
	energyTick+=delta
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
	if spectator:
		return
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
	var id=multiplayer.get_remote_sender_id()
	if id!=name.to_int():
		return
	if !is_multiplayer_authority():
		return
	if spectator:
		return
	for i in toggleSlots:
		if items[i]!=null:
			items[i].toggle()
	for i in useSlots:
		if items[i]!=null:
			items[i].attemptAbility(mousePos)
	for item in items:
		if item!=null&&item.autofire:
			item.attemptAbility(mousePos)

func doMovement(delta):
	rpc_id(1,"doMovementServer",delta,Input.get_vector("move_left","move_right","move_up","move_down"))

@rpc("any_peer", "call_local") func doMovementServer(delta,inputDir):
	var id=multiplayer.get_remote_sender_id()
	if id!=name.to_int():
		return
	if !is_multiplayer_authority():
		return
	accelerationDir=inputDir
	
	if accelerationDir.length()>0:
		accelerationDir=accelerationDir.normalized()


func _input(event):
	if multiplayer.get_unique_id()!=name.to_int():
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
	if d>=health:
		if source!=null:
			source.onKill(self)
		score=0
	super.takeDamage(d)
	timeSinceHit=0
func onKill(victim):
	score+=victim.score
	energy+=maxEnergy/2
	health+=maxHealth/6
	
func die():
	spectator=true
	$CollisionShape2D.disabled=true
	rpc_id(name.to_int(),"die_client")
@rpc("authority", "call_local", "reliable")
func die_client():
	get_node("CanvasLayer/DeathScreen").show()

func show_message(text):
	rpc_id(name.to_int(),"show_message_client",text)

@rpc("authority", "call_local", "reliable")
func show_message_client(text):
	if text==null:
		messageBox.hide()
	else:
		message.text=text
		messageBox.show()

func _on_respawn_pressed():
	rpc_id(1,"_on_respawn_pressed_server")
@rpc("any_peer", "call_local") func _on_respawn_pressed_server():
	var id=multiplayer.get_remote_sender_id()
	if id!=name.to_int() || !is_multiplayer_authority():
		return
	respawn.emit(id)

func _on_quit_pressed():
	rpc_id(1,"_on_quit_pressed_server")
	multiplayer.multiplayer_peer=null
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
@rpc("any_peer", "call_local") func _on_quit_pressed_server():
	var id=multiplayer.get_remote_sender_id()
	if id!=name.to_int() || !is_multiplayer_authority():
		return
	quit.emit(id)
	
func server_disconnected(): #doesn't work
	pass
