extends Projectile

var target
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
	if !is_multiplayer_authority():
		return

	if target:
		targetPos=target.position
	if startupDuration>0||autoTarget&&!target:
		startupDuration-=delta
		targetPos=owner2.position
		acceleration=2000
		speed=600
	if pattern==0:  #naive strategy
		accelerationDir=targetPos-position
	elif pattern==1:
		accelerationDir=(targetPos-position).normalized()-velocity.normalized()
		if accelerationDir.length()<0.1:
			accelerationDir=targetPos-position
	accelerationDir=accelerationDir.normalized()
	super(delta)


func _on_targeting_area_entered(area):
	if !is_multiplayer_authority():
		return
	if !autoTarget:
		return
	if !area.get_groups().has("player")||team==area.get("team"):
		return
	target=area
	
