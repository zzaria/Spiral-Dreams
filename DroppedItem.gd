extends Node2D
var item: Ability

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(item)
	item.position=Vector2(-29,-29)



func _on_area_entered(area):
	if !is_multiplayer_authority():
		return
	var pickedUp=area.pickUpItem(item)
	if pickedUp:
		remove_child(item)
		queue_free()
