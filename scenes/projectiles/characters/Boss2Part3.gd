extends Projectile

var movementRange=500
var randomSpot=Vector2.ZERO
var jumping
var jumpSpeed
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
	if jumping:
		targetPos=randomSpot
		acceleration=8000
		speed=jumpSpeed
		if position.distance_to(targetPos)<30:
			jumping=false
			doMovement()
	accelerationDir=(targetPos-position).normalized()-(velocity).normalized()
	if accelerationDir.length()<0.1:
		accelerationDir=targetPos-position
	accelerationDir=accelerationDir.normalized()

	if !jumping&&position.distance_to(owner2.position)>movementRange:
		velocity=velocity*(0.5**delta)+(owner2.position-position)/movementRange*speed*(1-0.5**delta)
		speed=1e9

func doMovement():
	while true:
		if is_instance_valid(owner2)&&owner2.target&&owner2.position.distance_to(owner2.target.position)<movementRange&&randi_range(0,2)==0:
			jumping=true
			randomSpot=owner2.target.position+(owner2.target.position-position)*0.1
			jumpSpeed=position.distance_to(randomSpot)/randf_range(0.35,0.5)
			return
		randomSpot=Vector2(randf_range(-movementRange,movementRange),randf_range(-movementRange,movementRange))
		$Timer.start(randf_range(3,8))
		await $Timer.timeout
