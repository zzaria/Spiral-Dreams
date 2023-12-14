extends Ability
class_name Gun
@export var bullet:PackedScene
@export var bulletSpeed=1000
@export var bulletHealth=2
@export var bulletLifespan=1.0

var count=0
func doAbility(mousePos):
	super.doAbility(mousePos)
	if mousePos==null:
		return
	var dir=mousePos
	if dir==Vector2.ZERO:
		dir=Vector2.DOWN
	dir=dir.normalized()*bulletSpeed
	var newBullet=bullet.instantiate()
	newBullet.init(bearer.position,dir,bearer,bearer.team,bulletLifespan,damage,bulletHealth)
	newBullet.name=str(randi())
	Global.spawnObject.emit(newBullet)
