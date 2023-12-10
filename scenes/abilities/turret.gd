extends Gun
@export var distance=200
var x=0
func doAbility(mousePos):
	super.doAbility(null)
	if mousePos==null:
		return
	x=(x+1)%4
	var pos=bearer.position+Vector2.from_angle(2*PI*(x/4.0+Global.time/20.0))*distance
	var dir=(mousePos+bearer.position-pos).normalized()*bulletSpeed

	var newBullet=bullet.instantiate()
	newBullet.init(pos,dir,bearer,bearer.team,bulletLifespan,damage,bulletHealth)
	newBullet.name=str(randi())
	Global.spawnObject.emit(newBullet)
