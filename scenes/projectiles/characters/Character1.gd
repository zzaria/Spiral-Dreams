extends TrackingProjectile
var bullet=load("res://scenes/projectiles/projectile_small.tscn")

var targetPos
var followDistance=500
func _ready():
	owner2=self
	super()
func init2(_position=Vector2.ZERO,_velocity=Vector2.ZERO,_owner2=null,_team=0):
	position=_position
	velocity=_velocity
	owner2=_owner2
	team=_team
	health=maxHealth

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
	var dir=(targetPos-position).normalized()*300
	var newBullet=bullet.instantiate()
	newBullet.init(position,dir,owner2,team,2,1,1)
	newBullet.name=str(randi())
	Global.spawnObject.emit(newBullet)
