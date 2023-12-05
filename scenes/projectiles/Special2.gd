extends Projectile
@export var subProjectile:PackedScene
@export var density=20
var targetPos
func init2(pos):
	targetPos=pos
func _physics_process2(_delta):
	if !is_multiplayer_authority():
		return
	if (targetPos-position).length()<50:
		velocity=Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func die():
	var offset=randf_range(0,2*PI)
	for i in range(density):
		var dir=Vector2.from_angle(i*2*PI/density+offset)*800
		var proj=subProjectile.instantiate()
		proj.init(position,dir,owner2,team,2,damage,health)
		proj.name=str(randi())
		Global.spawnObject.emit(proj)
	super()
