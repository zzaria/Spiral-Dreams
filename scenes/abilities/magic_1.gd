extends Gun
@export var harbinger:PackedScene
@export var delay=0.5
@export var beamWidth=4
@export var offset=0
var mousePos1
var mousePos2

func attemptAbility(mousePos):
	super(mousePos)

func doAbility(mousePos):
	mousePos2=mousePos1
	mousePos1=mousePos
	super.doAbility(null)
	var dir
	if mousePos2==null||(mousePos1-mousePos2).length()<0.1:
		dir=Vector2.from_angle(randf_range(0,2*PI))
	else:
		dir=mousePos1-mousePos2
		dir=dir.normalized()
	var newBullet=bullet.instantiate()
	newBullet.init(bearer.position+mousePos1-dir*offset,dir*bulletSpeed,bearer,bearer.team,bulletLifespan,damage,bulletHealth)
	newBullet.rotation=dir.angle()
	newBullet.name=str(randi())
	var h=harbinger.instantiate()
	h.lifeSpan=delay
	h.init2(bearer.position+mousePos1,dir,beamWidth,newBullet)
	Global.spawnObject.emit(h)
