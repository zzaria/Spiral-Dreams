extends Projectile

var movementRange=500
var targetRange=3000
# Called when the node enters the scene tree for the first time.
func _ready():
	doMovement()
	super()
	velocity=Vector2.from_angle(randf()*2*PI)

func _physics_process2(delta):
	super(delta)
	if !owner2:
		return
	if owner2.target:
		var targetPos=owner2.target.position
		if position.distance_to(targetPos)<targetRange:
			accelerationDir=(targetPos-position).normalized()-(velocity).normalized()
			if accelerationDir.length()<0.1:
				accelerationDir=targetPos-position
			accelerationDir=accelerationDir.normalized()
	if position.distance_to(owner2.position)>movementRange:
		velocity=velocity*(0.5**delta)+(owner2.position-position)*(1-0.5**delta)

func doMovement():
	while true:
		var newAcc=randf_range(500,2000)
		var tween=get_tree().create_tween()
		tween.tween_property(self,"acceleration",newAcc,1)
		$Timer.start(randf_range(10,20))
		await $Timer.timeout
