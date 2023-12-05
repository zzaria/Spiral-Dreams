class_name Player
extends Projectile
signal respawn
signal requestjointeamsignal
signal acceptteamrequestsignal
signal startgamesignal

var cam
var inventory
var items
var itemDisabled
var healthBar
var energyBar
var nametag
@export var zoomEnabled=false #can easily be bypassed
var zoomLevel=0

@export var maxImmunity =0
@export var baseMaxEnergy=1000
@export var maxEnergy=0
@export var energy=0
const inventorySize=50
const inventoryRows=5
const inventoryColumns=10
var hotbarRow=0
@export var score=1:
	set(value):
		if is_inside_tree():	
			get_node("CanvasLayer/TopLeftUi/ScoreDisplay/Label").text="Score: "+str(round(value))
var globalAttackCooldown=0
var energyTick=0
var timeSinceHit=0
var healthEnabled=false
@export var spectator=false
@export var id=-1
var dashing=false
@export var username=""
var teamRequests=[]

func initPlayer(_team,spawnPoint=Vector2.ZERO):
	team=_team
	health=maxHealth
	energy=baseMaxEnergy
	velocity=Vector2.ZERO
	position=spawnPoint
	spectator=false
	score=1
	owner2=self
	zoomLevel=0
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
	var slots=get_node("CanvasLayer/InventoryScreen/Inventory/GridContainer").get_children()
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
	if id!=multiplayer.get_remote_sender_id()||!is_multiplayer_authority():
		return
	if y==null||x==null||0>x||x>=inventorySize||0>y||y>=inventorySize:
		return
	var ix=items[x]
	var iy=items[y]
	setItem(y,ix)
	setItem(x,iy)
func inventorySlotRightClick_client(index):
	rpc_id(1,"inventorySlotRightClick",index)
@rpc("any_peer", "call_local","reliable")
func inventorySlotRightClick(index):
	if id!=multiplayer.get_remote_sender_id()||!is_multiplayer_authority():
		return
	if 0<=index&&index<inventorySize:
		itemDisabled[index]=!itemDisabled[index]


	
func resetInventory():
	items=[]
	itemDisabled=[]
	for i in range(0,inventorySize):
		items+=[null]
		itemDisabled+=[false]
	var i=0
	for item in Global.initialEquip:
		setItem(i,item.duplicate())
		i+=1
@rpc("any_peer", "call_local","reliable")
func setUsername(text):
	if id!=multiplayer.get_remote_sender_id()||!is_multiplayer_authority():
		return
	text=text.substr(0,25)
	username=text
		
# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	cam=$Camera2D
	cam.enabled=multiplayer.get_unique_id()==id
	$CanvasLayer.visible=multiplayer.get_unique_id()==id
	if multiplayer.get_unique_id()==id:
		setUsername.rpc_id(1,Global.username)
		inventory=get_node("CanvasLayer/InventoryScreen/Inventory")
		inventory.itemOwner=self
		
		healthBar=get_node("CanvasLayer/TopLeftUi/HealthBar")
		energyBar=get_node("CanvasLayer/TopLeftUi/EnergyBar")
		var slots=get_node("CanvasLayer/InventoryScreen/Inventory/GridContainer").get_children()
		var i=0
		for slot in slots:
			slot.index=i
			slot.dragSignal.connect(inventoryDrag)
			slot.dropSignal.connect(inventoryDrop)
			slot.rightClickSignal.connect(inventorySlotRightClick_client)
			i+=1
		if !is_multiplayer_authority():
			get_node("CanvasLayer/InventoryScreen/VBoxContainer/HostActions").hide()
	if is_multiplayer_authority():
		var timer = Timer.new()
		timer.connect("timeout",afsdlknj) 
		timer.set_one_shot(true)
		timer.set_wait_time(1) #bruh
		add_child(timer) 
		timer.start() 
	nametag=get_node("Nametag")
func afsdlknj():
	var i=0
	for item in items:
		if item!=null:
			rpc_id(id,"setItem_client",i,item.name)
		i+=1

func updateNameTag(): 
	nametag.text=str(team)+"-"+str(name)+"\n"+username

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)
	if spectator&&multiplayer.get_unique_id()!=id:
		self.hide()
	else:
		self.show()
	
	updateNameTag() #how to override setter for team and name?

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
	
	if multiplayer.get_unique_id()!=id:
		return
	
	healthBar.max_value=maxHealth
	healthBar.value=health
	healthBar.get_node("Label").text="Health: "+str(round(health))
	energyBar.max_value=maxEnergy
	energyBar.value=energy
	energyBar.get_node("Label").text="Energy: "+str(round(energy))

	for i in range(inventoryRows):
		if Input.is_action_pressed("hotbar"+str(i+1)):
			hotbarRow=i
	if Input.is_action_just_pressed("zoom_in"):
		zoomLevel+=1
	if Input.is_action_just_pressed("zoom_out"):
		zoomLevel-=1
	if !zoomEnabled:
		zoomLevel=0
	zoomLevel=clamp(zoomLevel,-3,3)
	var viewSize=get_viewport().size

	cam.zoom=Vector2.ONE*2.0**zoomLevel*min(viewSize.x/Global.VIEWPORT_SIZE.x,viewSize.y/Global.VIEWPORT_SIZE.y)
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
	
	var vp=velocity.dot(accelerationDir)*accelerationDir
	velocity-=(velocity-vp)*(1-0.5**(delta/0.05)) #velocity halves every 0.05s due to drag
		

func resetStats():
	super.resetStats()
	maxEnergy=baseMaxEnergy
	zoomEnabled=false

func doAbilities():
	var useSlots=[]
	var toggleSlots=[]
	for i in range(1,6):
		if Input.is_action_pressed("use"+str(i)):
			useSlots.append(hotbarRow*inventoryColumns+i-1)
		if Input.is_action_pressed("toggle"+str(i)):
			toggleSlots.append(hotbarRow*inventoryColumns+i-1)
	if len(useSlots)>0 || len(toggleSlots)>0:
		var mousePos=get_viewport().get_mouse_position()-Vector2(get_viewport().size/2)
		mousePos/=cam.zoom
		rpc_id(1,"doAbilitiesServer",mousePos,useSlots,toggleSlots)

@rpc("any_peer", "call_local") func doAbilitiesServer(mousePos,useSlots,toggleSlots):
	if id!=multiplayer.get_remote_sender_id()||!is_multiplayer_authority():
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

@rpc("any_peer", "call_local") func doMovementServer(_delta,inputDir):
	if id!=multiplayer.get_remote_sender_id()||!is_multiplayer_authority():
		return
	accelerationDir=inputDir
	
	if accelerationDir.length()>0:
		accelerationDir=accelerationDir.normalized()


func _input(event):
	if multiplayer.get_unique_id()!=id:
		return
	if event.is_action_pressed("inventory"):
		get_node("CanvasLayer/InventoryScreen").visible=!get_node("CanvasLayer/InventoryScreen").visible
		
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
	energy+=maxEnergy/2.0
	health+=maxHealth/6.0
	
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
	var messageBox=get_node("CanvasLayer/MessageBox")
	if text==null:
		messageBox.hide()
	else:
		messageBox.get_node("CenterContainer/Label").text=text
		messageBox.show()

func _on_respawn_pressed():
	rpc_id(1,"_on_respawn_pressed_server")
	get_node("CanvasLayer/DeathScreen").hide()
	
@rpc("any_peer", "call_local") func _on_respawn_pressed_server():
	if id!=multiplayer.get_remote_sender_id() || !is_multiplayer_authority():
		return
	respawn.emit(self)

func _on_quit_pressed():
	teamRequests=[]
	multiplayer.multiplayer_peer=null
	Global.changeLevel.emit("main_menu")


func _on_line_edit_text_submitted(new_text):
	requestjointeam.rpc_id(1,new_text)
	get_node("CanvasLayer/InventoryScreen/VBoxContainer/HBoxContainer/RequestTeam").text=""
@rpc("any_peer", "call_local") func requestjointeam(team):
	if id!=multiplayer.get_remote_sender_id() || !is_multiplayer_authority():
		return
	requestjointeamsignal.emit(id,team)

@rpc("authority", "call_local", "reliable") func showteamrequest(id,name):
	teamRequests+=[[id,name]]
	get_node("CanvasLayer/TeamRequests").show()
	get_node("CanvasLayer/TeamRequests/MarginContainer/VBoxContainer/Label").text="Add to team"+name+" "+str(id)+"?"



func _on_button_pressed():
	acceptteamrequest.rpc_id(1,teamRequests[0][0])
	teamRequests.remove_at(0)
	if teamRequests.size()==0:
		get_node("CanvasLayer/TeamRequests").hide()
@rpc("any_peer", "call_local") func acceptteamrequest(x):
	if id!=multiplayer.get_remote_sender_id() || !is_multiplayer_authority():
		return
	acceptteamrequestsignal.emit(x,name)
	




func _on_button_2_pressed():
	teamRequests.remove_at(0)
	if teamRequests.size()==0:
		get_node("CanvasLayer/TeamRequests").hide()


func _on_line_edit_2_text_changed(new_text):
	Global.password=new_text

func startgame():
	startgamesignal.emit()

@rpc("authority","call_local","reliable")
func setAllowedActions(team,respawn,levelStarted):
	get_node("CanvasLayer/DeathScreen/CenterContainer/VBoxContainer/CenterContainer/HBoxContainer/Respawn").visible=respawn
	get_node("CanvasLayer/InventoryScreen/VBoxContainer/HBoxContainer/RequestTeam").visible=team
	get_node("CanvasLayer/InventoryScreen/VBoxContainer/HostActions/Button").text="End game" if levelStarted else "Start game"
	
