extends Projectile

var target
var targetPos
var autoTarget
func init2(pos,_autoTarget=false):
	targetPos=pos
	autoTarget=_autoTarget

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	if target:
		targetPos=target.position
	accelerationDir=targetPos-position #naive strategy
	accelerationDir=accelerationDir.normalized()
	super(delta)


func _on_targeting_area_entered(area):
	if !is_multiplayer_authority():
		return
	if !autoTarget:
		return
	if !area.get_groups().has("player")||team==area.get("team"):
		return
	print_debug(area.name)
	target=area
	
