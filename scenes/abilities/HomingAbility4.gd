extends Gun
@export var acceleration=3000
@export var pattern=1
@export var spread=24

func doAbility(mousePos):
	super.doAbility(null)
	if mousePos==null:
		return
	var dir=mousePos.normalized()
	if dir==Vector2.ZERO:
		dir=Vector2.DOWN
	dir=dir.normalized()
	for i in range(-2,3):
		var dir2=dir.rotated(2*PI/spread*i)
		var newBullet=bullet.instantiate()
		newBullet.init(bearer.position,dir2*1200,bearer,bearer.team,bulletLifespan,damage,bulletHealth)
		newBullet.init2(pattern,mousePos+bearer.position,bulletSpeed,acceleration,false)
		newBullet.name=str(randi())
		bearer.get_tree().get_nodes_in_group("level")[0].add_child(newBullet)
