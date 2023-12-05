extends TrackingProjectile
var explosion=load("res://scenes/projectiles/Explosion.tscn")

var targetPos
var autoTarget
var pattern=0
var preflightTime=0
var boostTime=0
func init2(_pattern,pos,_speed,_acceleration,_autoTarget):
	pattern=_pattern
	baseSpeed=_speed
	baseAcceleration=_acceleration
	targetPos=pos
	autoTarget=_autoTarget
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process2(delta):
	if autoTarget:
		if target:
			targetPos=target.position
		elif velocity!=Vector2.ZERO:
			targetPos=position+velocity.normalized()*100
	if (targetPos-position).length()<50:
		lifeSpan=0
	if pattern==0:  #naive strategy
		accelerationDir=targetPos-position
	elif pattern==1:
		accelerationDir=(targetPos-position).normalized()-velocity.normalized()
		if accelerationDir.length()<0.1:
			accelerationDir=targetPos-position
	elif pattern==2:
		acceleration=0
		var decay=min(1,0.257778 *lifeSpan + 0.0531111) if lifeSpan>0.5 else 1
		velocity=(targetPos-position).normalized()*speed*(1-decay**delta)+velocity*(decay**delta)
	accelerationDir=accelerationDir.normalized()
	super(delta)
func die():
	var e=explosion.instantiate()
	e.init(position,Vector2.ZERO,owner2,team,0.2,damage,1000)
	e.init2(200)
	e.name=str(randi())
	Global.spawnObject.emit(e)
	super()#


	

	
