extends TrackingProjectile
var bullet=load("res://scenes/projectiles/projectile_small.tscn")

var targetPos
@export var followDistance=300

func _ready():
	owner2=self
	super()
func init2(_position,_team,_owner2=null):
	position=_position
	team=_team
	if owner2:
		owner2=_owner2
		team=owner2.team

func _physics_process2(delta):
	if !is_multiplayer_authority():
		return
	targetPos=target.position if target else null
	if targetPos&&(targetPos-position).length()>followDistance:
		velocity=(targetPos-position).normalized()*speed
	else:
		velocity=Vector2.ZERO

	super(delta)



func _on_timer_timeout():
	if !is_multiplayer_authority():
		return
	if !targetPos:
		return
	var dir=(targetPos-position).normalized()*600
	var newBullet=bullet.instantiate()
	newBullet.init(position,dir,owner2,team,2,1,1)
	newBullet.name=str(randi())
	Global.spawnObject.emit(newBullet)
