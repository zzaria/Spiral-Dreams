extends Gun
@export var acceleration=3000
@export var pattern=0
var inEffect=false
var prevDuration
var delay=1.0/60
var mousePos1

func doAbility(mousePos):
	super.doAbility(null)
	inEffect=true
	prevDuration=duration
	mousePos1=mousePos+bearer.position
func doAbilityTimeout():
	inEffect=false
func doEffect():
	if inEffect:
		while prevDuration>durationTimer:
			prevDuration-=delay
			var pos0=bearer.position+Vector2.from_angle(randf_range(0,2*PI))*randf_range(0,100)
			var newBullet=bullet.instantiate()
			newBullet.init(pos0,Vector2.ZERO,bearer,bearer.team,bulletLifespan,damage,bulletHealth)
			newBullet.init2(pattern,mousePos1,bulletSpeed,acceleration,true)
			newBullet.name=str(randi())
			Global.spawnObject.emit(newBullet)
			await newBullet.ready
			newBullet.find_new_target(mousePos1)

