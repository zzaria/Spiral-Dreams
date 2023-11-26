extends Gun

func doAbility(mousePos):
	super.doAbility(null)
	if mousePos==null:
		return
	mousePos
	var newBullet=bullet.instantiate()
	newBullet.init(bearer.position,Vector2.DOWN*100,bearer,bearer.team,bulletLifespan,damage,bulletHealth)
	newBullet.init2(mousePos+bearer.position,true)
	newBullet.name=str(randi())
	bearer.get_tree().get_nodes_in_group("level")[0].add_child(newBullet)
