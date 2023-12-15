extends Character
var bulletSmall=load("res://scenes/projectiles/projectile_small.tscn")
var bulletLarge=load("res://scenes/projectiles/projectile_large.tscn")
var nextShot=0
@export var bulletSpeed1=800
@export var bulletSpeed2=1150
@export var bulletSpeed3=1350
var targetPos
@export var baseFollowDistance=500
var followDistance=0
var state
var state2=0

func _ready():
	score=1
	followDistance=baseFollowDistance
	super()
	setState(100)

func _physics_process2(delta):
	if !is_multiplayer_authority():
		return
	if state!=1:
		followTarget(delta)
	if state==5||state==6:
		if nextShot<Global.time:
			if state==5:
				nextShot=Global.time+randf_range(0.3,0.55)
				bulletSpeed3=1600
			elif state==6&&state2==0:
				nextShot=Global.time+0.22
				bulletSpeed3=1350
			elif state==6&&state2==1:
				nextShot=Global.time+0.16
				bulletSpeed3=1700
			

			var newBullet=bulletSmall.instantiate()
			newBullet.init(position,(targetPos-position).normalized()*bulletSpeed3,owner2,team,5,1,10)
			newBullet.name=str(randi())
			Global.spawnObject.emit(newBullet)

	super(delta)
func followTarget(delta):
	targetPos=target.position if target else null
	if targetPos:
		if (targetPos-position).length()>followDistance:
			velocity=(targetPos-position).normalized()*speed
		else:
			velocity*=0.04**delta
func setState(x):
	state=x
	match state:
		0:
			if state2==0&&health<maxHealth*0.5:
				state2=1
			setState(randi_range(1,4))
		1:
			velocity=Vector2.ZERO
			var tween=get_tree().create_tween()
			tween.tween_property(self,"position",targetPos,0.5)
			$Timer.start(2)
			await $Timer.timeout
			setState(100)
		2:
			var t=0.0
			for i in range(2,-5,-1):
				var t1=t+2.0**i
				var newPos=target.position+target.velocity*t1
				if (newPos-position).length()/bulletSpeed1>=t1:
					t=t1
			var newBullet=bulletLarge.instantiate()
			var dir=(target.position+target.velocity*t-position).normalized()*bulletSpeed1
			newBullet.init(position,dir,owner2,team,5,1,10)
			newBullet.name=str(randi())
			Global.spawnObject.emit(newBullet)
			setState(100)
		3:
			var offset=randf()
			var delay=randi_range(0,1)
			var chirality=[-1,1].pick_random()
			for i in range(0,10):
				var dir=Vector2.from_angle(2*PI*(i/10.0*chirality+offset))*bulletSpeed1
				var newBullet=bulletSmall.instantiate()
				newBullet.init(position,dir,owner2,team,5,1,1)
				newBullet.name=str(randi())
				Global.spawnObject.emit(newBullet)
				if delay==1:
					$Timer.start(0.07)
					await $Timer.timeout
			setState(100)
		4:
			for j in range(2):
				var t=0.0
				for i in range(2,-5,-1):
					var t1=t+2.0**i
					var newPos=target.position+target.velocity*t1
					if (newPos-position).length()/bulletSpeed2>=t1:
						t=t1
				var dir=(target.position+target.velocity*t-position).normalized()*bulletSpeed2
				var newBullet=bulletSmall.instantiate()
				newBullet.init(position,dir,owner2,team,5,1,1)
				newBullet.name=str(randi())
				Global.spawnObject.emit(newBullet)
				$Timer.start(0.2)
				await $Timer.timeout
			setState(100)
		100:
			$Timer.start(3)
			await $Timer.timeout
			setState(0)
