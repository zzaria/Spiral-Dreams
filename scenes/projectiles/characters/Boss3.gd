extends Character
var bullet=load("res://scenes/projectiles/projectile_small.tscn")
var minion=load("res://scenes/projectiles/characters/Character6.tscn")

var targetPos
var followDistance=50
var state=0
var shootSpeed=1000
var nextShot=0
var dead=false

func _ready():
	state=-1
	doPatternCycle()
	super()

func _physics_process2(delta):
	if !is_multiplayer_authority():
		return
	
	if target:
		targetPos=target.position
		if target&&nextShot<Global.time:
			nextShot=Global.time+0.25
			shoot((targetPos-position).normalized()*shootSpeed)
			if state==2:
				var t=0.0
				for i in range(2,-5,-1):
					var t1=t+2.0**i
					var newPos=targetPos+target.velocity*t1
					if (newPos-position).length()/shootSpeed>=t1:
						t=t1
				shoot((targetPos+target.velocity*t-position).normalized()*shootSpeed)
	if targetPos!=null&&(targetPos-position).length()>followDistance:
		accelerationDir=targetPos-position
		accelerationDir=accelerationDir.normalized()
	super(delta)

func doPatternCycle():
	while true:
		if state==0:
			var m=minion.instantiate()
			m.init(position,Vector2.from_angle(randf()*2*PI)*500,owner2,team,-1000000,0,50)
			m.name="minion"+str(randi())
			Global.spawnObject.emit(m)
		$Timer.start(15)
		await $Timer.timeout
		state+=1
		if state==3:
			state=0
func die():
	if dead:
		return
	dead=true
	for i in range(3):
		var m=minion.instantiate()
		m.init(position,Vector2.from_angle(randf()*2*PI)*500,owner2,team,-1000000,0,50)
		m.name="minion"+str(randi())
		m.type=i
		Global.spawnObject.emit(m)
	super()




func _on_timer_timeout():
	if !is_multiplayer_authority():
		return
	shoot((targetPos-position).normalized()*speed)
	
func shoot(dir):
	var newBullet=bullet.instantiate()
	newBullet.init(position,dir,owner2,team,3,1,1)
	newBullet.name=str(randi())
	Global.spawnObject.emit(newBullet)
