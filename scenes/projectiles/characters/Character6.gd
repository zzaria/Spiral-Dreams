extends Character
var bullet=load("res://scenes/projectiles/projectile.tscn")

var targetPos
var followDistance=400
var type=0

func _ready():
	owner2=self
	super()

func _physics_process2(delta):
	if !is_multiplayer_authority():
		return
	if target:
		if position.distance_to(target.position)<followDistance:
			speed*=4
			acceleration*=2
			if position.distance_to(target.position)<followDistance/2.0:
				speed*=8
				acceleration*=8
		var dir=target.velocity if target.velocity.length()>10 else target.position-position
		var p1=target.position-dir.normalized()*followDistance
		var p2=target.position+dir.normalized()*followDistance*2
		targetPos=p1 if target.velocity.length()<10||type!=2&&(type==1||(p1-position).length()<(p2-position).length()) else p2
	if targetPos!=null&&(targetPos-position).length()>10:
		accelerationDir=targetPos-position
		accelerationDir=accelerationDir.normalized()
	else:
		accelerationDir=Vector2.ZERO
	var vp=velocity.dot(accelerationDir)*accelerationDir
	velocity-=(velocity-vp)*(1-0.5**(delta/0.05))
	super(delta)

func _on_timer_timeout():
	if !is_multiplayer_authority():
		return
	if !target:
		return
	const speed=900.0
	var dir=(target.position-position).normalized()*speed
	var newBullet=bullet.instantiate()
	newBullet.init(position,dir,owner2,team,3,1,1)
	newBullet.name=str(randi())
	Global.spawnObject.emit(newBullet)


