extends TrackingProjectile
var bullet=load("res://scenes/projectiles/projectile_small.tscn")

var targetPos
var followDistance=50

func _ready():
	owner2=self
	super()

func _physics_process2(delta):
	if !is_multiplayer_authority():
		return
	if target:
		targetPos=target.position
	if targetPos!=null&&(targetPos-position).length()>followDistance:
		accelerationDir=targetPos-position
		accelerationDir=accelerationDir.normalized()
	super(delta)


func _on_timer_timeout():
	if !is_multiplayer_authority():
		return
	if !targetPos:
		return
	var dir=(targetPos-position).normalized()*1500
	var newBullet=bullet.instantiate()
	newBullet.init(position,dir,owner2,team,3,1,1)
	newBullet.name=str(randi())
	Global.spawnObject.emit(newBullet)
