extends Gun
@export var acceleration=3000
@export var pattern=1

func doAbility(mousePos):
	super.doAbility(null)
	if mousePos==null:
		return
	var pos0=bearer.position+Vector2.from_angle(randf_range(0,2*PI))*randf_range(0,100)
	var newBullet=bullet.instantiate()
	newBullet.init(pos0,Vector2.ZERO,bearer,bearer.team,bulletLifespan,damage,bulletHealth)
	newBullet.init2(pattern,mousePos+bearer.position,bulletSpeed,acceleration,false)
	newBullet.name=str(randi())
	Global.spawnObject.emit(newBullet)
