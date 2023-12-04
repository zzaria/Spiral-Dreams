extends Projectile
class_name TrackingProjectile

var target
@export var targetDistance=0
@export var untargetDistance=0
func _ready():
	get_node("Area2D/CollisionShape2D").shape.radius=targetDistance
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if target&&(!is_instance_valid(target)||target.get("spectator")||position.distance_to(target.position)>untargetDistance):
		target=null
		find_new_target()
	super(delta)
func find_new_target(pos=position):
	var chars=get_tree().get_nodes_in_group("character")
	var minDistance=targetDistance
	for char in chars:
		if char.get_groups().has("character")&&team!=char.get("team")&&!char.get("spectator"):
			if pos.distance_to(char.position)<minDistance:
				target=char
				minDistance=pos.distance_to(char.position)
func _on_targeting_area_entered(area):
	if !is_multiplayer_authority():
		return
	if !target&&area.get_groups().has("character")&&team!=area.get("team")&&!area.get("spectator"):
		target=area
	

	
