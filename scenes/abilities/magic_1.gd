extends Gun
@export var harbinger:PackedScene
@export var delay=0.5
var mousePos1
var mousePos2

func attemptAbility(mousePos):
	if clampMouse&&mousePos!=null:
		mousePos=mousePos.clamp(-Global.VIEWPORT_SIZE/2,Global.VIEWPORT_SIZE/2)
	mousePos2=mousePos1
	mousePos1=mousePos
	super(null)

func doAbility(_mousePos):
	super.doAbility(null)
	var dir
	if mousePos2==null||(mousePos1-mousePos2).length()<0.1:
		dir=Vector2.from_angle(randf_range(0,2*PI))
	else:
		dir=mousePos1-mousePos2
		dir=dir.normalized()
	var newBullet=bullet.instantiate()
	newBullet.init(bearer.position+mousePos1-dir*1250,dir*bulletSpeed,bearer,bearer.team,bulletLifespan,damage,bulletHealth)
	newBullet.name=str(randi())
	var h=harbinger.instantiate()
	h.lifeSpan=delay
	h.init2(bearer.position+mousePos1,dir,newBullet)
	bearer.get_tree().get_nodes_in_group("level")[0].add_child(h)
