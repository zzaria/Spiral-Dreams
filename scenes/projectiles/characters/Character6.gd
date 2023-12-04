extends TrackingProjectile
var bullet=load("res://scenes/projectiles/projectile.tscn")

var targetPos
var followDistance=300

func _ready():
	owner2=self
	super()

func _physics_process2(delta):
	if !is_multiplayer_authority():
		return
	if target:
		var dir=target.velocity if target.velocity.length()>10 else target.position-position
		var p1=target.position-dir.normalized()*followDistance
		var p2=target.position+dir.normalized()*followDistance
		targetPos=p1 if (p1-position).length()<(p2-position).length() else p2
	if targetPos!=null&&(targetPos-position).length()>10:
		accelerationDir=targetPos-position
		accelerationDir=accelerationDir.normalized()
	else:
		accelerationDir=Vector2.ZERO
	var vp=velocity.dot(accelerationDir)*accelerationDir
	velocity-=(velocity-vp)*(1-0.5**(delta/0.05)) #velocity halves every 0.05s due to drag
	super(delta)

func _on_timer_timeout():
	if !is_multiplayer_authority():
		return
	if !targetPos:
		return
	const speed=1300.0
	var dir=(target.position-position).normalized()*speed
	var newBullet=bullet.instantiate()
	newBullet.init(position,dir,owner2,team,3,1,1)
	newBullet.name=str(randi())
	get_tree().get_nodes_in_group("level")[0].add_child(newBullet)
