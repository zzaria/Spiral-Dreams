extends Gun
@export var acceleration=3000
@export var pattern=0

func doAbility(mousePos):
	super.doAbility(null)
	if mousePos==null:
		return
	for i in range(4):
		var dir=Vector2.from_angle(randf_range(0,2*PI))
		var newBullet=bullet.instantiate()
		newBullet.init(bearer.position,dir*1000,bearer,bearer.team,bulletLifespan,damage,bulletHealth)
		newBullet.init2(pattern,bearer.position,bulletSpeed,acceleration,true,0.5)
		newBullet.name=str(randi())
		bearer.get_tree().get_nodes_in_group("level")[0].add_child(newBullet)
