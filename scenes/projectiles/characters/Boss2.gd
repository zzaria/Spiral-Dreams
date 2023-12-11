extends Character
var bulletSmall=load("res://scenes/projectiles/projectile_small.tscn")
var bulletMedium=load("res://scenes/projectiles/projectile.tscn")
var bossPart1=load("res://scenes/projectiles/characters/Boss2Part1.tscn")
var bossPart2=load("res://scenes/projectiles/characters/Boss2Part2.tscn")
var bossPart3=load("res://scenes/projectiles/characters/Boss2Part3.tscn")
var nextShot=0
@export var bulletSpeed1=800
var targetPos
@export var baseFollowDistance=5
@export var baseFollowDistance2=300
@export var baseFollowDistance3=500
var followDistance=0
var state
var state2=0


@export var jumpDistance=400
var inJumpRange=false
var jumping=false
@export var jumpDelay=3.0
@export var jumpDuration=0.1
var jumpSpeed
var jumpTime=0
var x=0

func _ready():
	followDistance=baseFollowDistance
	jumpSpeed=2.0*baseFollowDistance2/jumpDuration
	super()
	setState(100)

func resetStats():
	followDistance=baseFollowDistance
	super()

func _physics_process2(delta):
	if !is_multiplayer_authority():
		return
	if jumping:
		acceleration=0
		if jumpTime<Global.time:
			jumping=false
			jumpTime=Global.time+jumpDelay-jumpDuration
	elif target:
		if state<1000:
			if state==1:
				speed=500
				followDistance=baseFollowDistance2
			elif state==2:
				speed=100
			if (target.position-position).length()>followDistance:
				velocity=(target.position-position).normalized()*speed
			else:
				velocity=Vector2.ZERO	
		else:
			followDistance=baseFollowDistance3
			acceleration=position.distance_to(target.position)/followDistance*500
			if position.distance_to(target.position)>followDistance:
				speed=10000
			else:
				if velocity.length()>2000:
					velocity*=0.5**(delta/0.2)
				speed=max(800,velocity.length()*0.5**(delta/0.5))

			bulletSpeed1=1000
				
			accelerationDir=(target.position-position).normalized()-velocity.normalized()
			if accelerationDir.length()<0.1:
				accelerationDir=target.position-position
			accelerationDir=accelerationDir.normalized()
		if state==1:
			if (target.position-position).length()<jumpDistance:
				if jumpTime<Global.time:
					jumping=true
					jumpTime=Global.time+jumpDuration
					velocity=(target.position-position).normalized()*jumpSpeed
					acceleration=0
		elif state==2:
			if nextShot<Global.time:
				nextShot=max(nextShot,Global.time-0.05)
				nextShot+=0.1
				x=(x+1)%4
				var pos=position+Vector2.from_angle(2*PI*(x/4.0+Global.time*0.5))*200
				var dir=(target.position-pos).normalized()*bulletSpeed1
				var newBullet=bulletMedium.instantiate()
				newBullet.init(pos,dir,self,team,3,1,1)
				newBullet.name=str(randi())
				Global.spawnObject.emit(newBullet)
		else:
			if nextShot<Global.time:
				nextShot=Global.time+1.5
				for i in range(4):
					var pos=position+Vector2.from_angle(2*PI*(i/4.0+1/8.0))*120
					var dir=(target.position-pos).normalized()*bulletSpeed1
					var newBullet=bulletMedium.instantiate()
					newBullet.init(pos,dir,owner2,team,1,1,1)
					newBullet.name=str(randi())
					Global.spawnObject.emit(newBullet)
				
	super(delta)

func setState(x):
	state=x
	print_debug(state)
	match state:
		0:
			if health<maxHealth*0.5:
				for i in range(10):
					spawnMinion()
				setState(1000)
				return
			setState(randi_range(1,1))
		1:
			jumping=false
			$Timer.start(5)
			await $Timer.timeout
			setState(100)
		2:
			$Timer.start(7)
			await $Timer.timeout
			setState(100)
		100:
			$Timer.start(10)
			await $Timer.timeout
			setState(0)
		1000:
			spawnMinion()
			$Timer.start(5)
			await $Timer.timeout
			setState(1000)

func spawnMinion():
	var r=randi_range(0,99)
	if r<25:
		var part=bossPart2.instantiate()
		part.init(position,Vector2.ZERO,owner2,team,-1000000,10,50)
		part.name="part2"+str(randi())
		Global.spawnObject.emit(part)
	elif r<50:
		var part=bossPart3.instantiate()
		part.init(position,Vector2.ZERO,owner2,team,-1000000,10,50)
		part.name="part2"+str(randi())
		Global.spawnObject.emit(part)
	else:
		var part=bossPart1.instantiate()
		part.init(Vector2.ZERO,Vector2.ZERO,owner2,team,-1000000,10,50)
		part.name="part1"+str(randi())
		add_child(part)
