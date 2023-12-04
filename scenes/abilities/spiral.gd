extends Gun

var rotationSpeed=0.2
var timer=0

func updateTimer(delta):
	super.updateTimer(delta)
	timer+=delta

func doAbility(_mousePos):
	super.doAbility(null)
	var dir=Vector2.DOWN.rotated(timer*2*PI*rotationSpeed)
	for i in range(0,6):
		dir=dir.rotated(PI*2/6)
		var newBullet=bullet.instantiate()
		newBullet.init(bearer.position,dir*bulletSpeed,bearer,bearer.team,bulletLifespan,damage,bulletHealth)
		newBullet.name=str(randi())
		bearer.get_tree().get_nodes_in_group("level")[0].add_child(newBullet)
