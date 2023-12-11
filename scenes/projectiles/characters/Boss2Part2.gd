extends Projectile

var movementRange=500
var targetRange=500
var randomSpot=Vector2.ZERO
var baseAcceleration2=800
# Called when the node enters the scene tree for the first time.
func _ready():
	doMovement()
	super()
	velocity=Vector2.from_angle(randf()*2*PI)

func _physics_process2(delta):
	super(delta)
	if !owner2:
		return
	var targetPos=randomSpot+owner2.position
	accelerationDir=targetPos-position
	if owner2.target&&position.distance_to(owner2.target.position)<targetRange:
		targetPos=owner2.target.position
		acceleration=baseAcceleration2
		accelerationDir=(targetPos-position).normalized()-(velocity).normalized()
		if accelerationDir.length()<0.1:
			accelerationDir=targetPos-position
	accelerationDir=accelerationDir.normalized()
	if position.distance_to(owner2.position)>movementRange:
		velocity=velocity*(0.5**delta)+(owner2.position-position)/movementRange*speed*(1-0.5**delta)
		speed=1e9

func doMovement():
	while true:
		randomSpot=Vector2(randf_range(-movementRange,movementRange),randf_range(-movementRange,movementRange))
		$Timer.start(randf_range(3,8))
		await $Timer.timeout
