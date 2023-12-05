extends Projectile
@export var subProjectile:PackedScene
@export var subSpeed=1000
@export var subLifespan=1.0
@export var subCoolDown=1.0
@export var subHealth=1.0
@export var count=1
@export var spinSpeed=0.0
var spin=0

func _ready():
	$Timer.start(subCoolDown)

func _process(delta):
	spin+=delta
	rotation=2*PI*spin*spinSpeed
	super(delta)

func _on_timer_timeout():
	for i in range(count):
		var dir=Vector2.from_angle(i*2*PI/count+spin*2*PI*spinSpeed)*subSpeed
		var proj=subProjectile.instantiate()
		proj.init(position,dir,owner2,team,subLifespan,damage,subHealth)
		proj.name=str(randi())
		Global.spawnObject.emit(proj)
