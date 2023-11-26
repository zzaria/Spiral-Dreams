extends Gun
@export var spread=24
@export var bulletSecondary:PackedScene
func doAbility(mousePos):
	super.doAbility(null)
	if mousePos==null:
		return
	var dir=mousePos
	if dir==Vector2.ZERO:
		dir=Vector2.DOWN
	
	dir=dir.normalized()*bulletSpeed
	for i in range(-2,3):
		var dir2=dir.rotated(2*PI/spread*i)
		var newBullet=bullet.instantiate() if i==0 else bulletSecondary.instantiate()
		newBullet.init(bearer.position,dir2,bearer,bearer.team,bulletLifespan,damage,bulletHealth)
		newBullet.name=str(randi())
		bearer.get_tree().get_nodes_in_group("level")[0].add_child(newBullet)
