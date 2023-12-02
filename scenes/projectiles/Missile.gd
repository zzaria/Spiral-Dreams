extends Projectile
var explosion=load("res://scenes/projectiles/Explosion.tscn")

var target
var targetPos
var autoTarget
var pattern=0
func init2(_pattern,pos,_speed,_acceleration,targetRadius,_autoTarget=false):
	pattern=_pattern
	baseSpeed=_speed
	baseAcceleration=_acceleration
	targetPos=pos
	get_node("Area2D/CollisionShape2D").shape.radius=targetRadius
	autoTarget=_autoTarget

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	if target:
		targetPos=target.position
	if (targetPos-position).length()<50:
		lifeSpan=0
	if pattern==0:  #naive strategy
		accelerationDir=targetPos-position
	elif pattern==1:
		accelerationDir=(targetPos-position).normalized()-velocity.normalized()
		if accelerationDir.length()<0.1:
			accelerationDir=targetPos-position
	accelerationDir=accelerationDir.normalized()
	super(delta)
func die():
	var e=explosion.instantiate()
	e.init(position,Vector2.ZERO,owner2,team,0.2,damage,1000)
	e.init2(200)
	e.name=str(randi())+"e"
	self.get_tree().get_nodes_in_group("level")[0].add_child(e)
	super()



func _on_targeting_area_entered(area):
	if !is_multiplayer_authority():
		return
	if !autoTarget:
		return
	if !area.get_groups().has("player")||team==area.get("team"):
		return
	target=area
func takeDamage(a,b=null):
	super(a,b)
	
