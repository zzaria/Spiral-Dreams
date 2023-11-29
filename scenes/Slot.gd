extends Panel

signal dragSignal(index)
signal dropSignal(index)
signal rightClickSignal(index)
@export var item:ability=null
var inventory
var index
var disabled=false

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory=find_parent("Inventory")

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index==MOUSE_BUTTON_LEFT&&event.pressed:
			var temp=item
			if inventory.heldItem!=null:
				drop(inventory.heldItem)
				inventory.heldItem=null
			elif temp!=null:
				drag()
				temp.global_position=get_viewport().get_mouse_position()
				inventory.heldItem=temp
		elif event.button_index==MOUSE_BUTTON_RIGHT&&event.pressed:
			rightClickSignal.emit(index)
			disabled=!disabled
	if disabled:
		modulate=Color("#333333")
	else:
		modulate=Color("#ffffff")

			
@rpc("authority", "call_local", "reliable")
func setItem(_itemname):
	clearItem()
	if _itemname==null:
		return
	var _item
	for i in Global.itemList:
		if i.name==_itemname:
			_item=i
			break
	if _item==null:
		return
	item=_item
	add_child(item)
	item.position=Vector2.ZERO
func clearItem():
	if item==null:
		return
	remove_child(item)	
	item=null

func drag():
	var temp=item
	clearItem()
	inventory.add_child(temp)
	dragSignal.emit(index)
	
func drop(_item):
	inventory.remove_child(_item)
	dropSignal.emit(index)
