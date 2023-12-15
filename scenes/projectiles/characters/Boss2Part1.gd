extends Projectile

var movementRange=500
# Called when the node enters the scene tree for the first time.
func _ready():
	doMovement()
	super()


func doMovement():
	while true:
		var newPos=Vector2(randf_range(-movementRange,movementRange),randf_range(-movementRange,movementRange))
		var tween=get_tree().create_tween()
		tween.tween_property(self,"position",newPos,randf_range(1,2))
		$Timer.start(randf_range(3,5))
		await $Timer.timeout

func die():
	if is_instance_valid(owner2):
		owner2.bossPartCount[0]-=1
	super()
