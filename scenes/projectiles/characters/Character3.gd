extends Character
var bullet=load("res://scenes/projectiles/projectile_small.tscn")

var targetPos
var followDistance=50

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
	if !target:
		return
	const speed=1000.0
	var t=0.0
	for i in range(2,-5,-1):
		var t1=t+2.0**i
		var newPos=targetPos+target.velocity*t1
		if (newPos-position).length()/speed>=t1:
			t=t1
	shoot((targetPos+target.velocity*t-position).normalized()*speed)
	shoot((targetPos-position).normalized()*speed)
	
func shoot(dir):
	var newBullet=bullet.instantiate()
	newBullet.init(position,dir,owner2,team,3,1,1)
	newBullet.name=str(randi())
	Global.spawnObject.emit(newBullet)
