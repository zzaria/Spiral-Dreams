extends Ability
@export var bullet:PackedScene
@export var bulletSpeed=1000
@export var bulletHealth=2
@export var bulletLifespan=1.0

@export var cooldown2=0
@export var cooldown2Accumulation=0
var cooldownTimer2=0
func updateTimer(delta):
	cooldownTimer2-=delta
	super(delta)
	
func doAbility(mousePos):
	if cooldownTimer2>0:
		return
	cooldownTimer2=max(cooldownTimer2,-cooldown2*cooldown2Accumulation)
	cooldownTimer2+=cooldown2
	super(mousePos)
	if mousePos==null:
		return
	var dir=mousePos
	if dir==Vector2.ZERO:
		dir=Vector2.DOWN
	dir=dir.normalized()*bulletSpeed
	var newBullet=bullet.instantiate()
	newBullet.init(bearer.position,dir,bearer,bearer.team,bulletLifespan,damage,bulletHealth)
	newBullet.init2(mousePos+bearer.position)
	newBullet.name=str(randi())
	Global.spawnObject.emit(newBullet)
