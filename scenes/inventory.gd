extends Control

const SlotClass=preload("res://scenes/Slot.gd")
var itemOwner
var heldItem=null
			
func _input(event):
	if heldItem!=null:
		heldItem.global_position=get_viewport().get_mouse_position()
