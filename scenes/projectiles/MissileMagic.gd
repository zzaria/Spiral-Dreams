extends TrackingProjectile
var targetPos
var autoTarget
var pattern=0
var startupDuration
func init2(_pattern,pos,_speed,_acceleration,_autoTarget=false,_startupDuration=0):
	pattern=_pattern
	baseSpeed=_speed
	baseAcceleration=_acceleration
	targetPos=pos
	autoTarget=_autoTarget
	startupDuration=_startupDuration

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process2(delta):
	if autoTarget:
		if target:
			targetPos=target.position
		else:
			targetPos=position+velocity*100
	if startupDuration>0||autoTarget&&!target:
		startupDuration-=delta
		targetPos=owner2.position
		acceleration=2000
		speed=600
		accelerationDir=(targetPos-position).normalized()
	elif pattern==0:  
		accelerationDir=(targetPos-position).normalized()
		var vp=velocity.dot(accelerationDir)*accelerationDir
		velocity-=(velocity-vp)*(1-0.5**(delta/0.5))
	elif pattern==1:
		accelerationDir=(targetPos-position).normalized()-velocity.normalized()
		if accelerationDir.length()<0.1:
			accelerationDir=targetPos-position
		accelerationDir=accelerationDir.normalized()
	super(delta)

