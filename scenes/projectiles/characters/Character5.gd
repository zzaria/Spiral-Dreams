extends TrackingProjectile
var bullet=load("res://scenes/projectiles/projectile_small.tscn")
var enemy=load("res://scenes/projectiles/characters/Character1.tscn")

var targetPos
@export var baseFollowDistance=400
var followDistance=0
var spinSpeeds=[2**0.5,3.0/37,2.0/31,1.0/16*0.995,1.0/10*0.995,1.0/7*0.99,1.0/5*0.99,1.0/4*0.99,1.0/3*0.99,1.0/2*0.99,1.0-0.01,0]
var spinIndex=0
var spinSpeed=2**0.5
var spin=0
var spinMultiplier=1
var time=0
var cooldown=0.03
var pattern=0

func _ready():
	owner2=self
	super()

func resetStats():
	followDistance=baseFollowDistance
	super()

func _physics_process2(delta):
	if !is_multiplayer_authority():
		return
	if pattern==1||pattern==3:
		speed=200
		followDistance=50
	if pattern==2||pattern==3:
		if randf_range(0,3)<delta: #linear approximation
			spawnEnemy()
	if target:
		targetPos=target.position
	if targetPos!=null&&(targetPos-position).length()>followDistance:
		accelerationDir=targetPos-position
		accelerationDir=accelerationDir.normalized()
		velocity*=0.8**delta
	time+=delta
	while time>0:
		time-=cooldown
		shoot1()
	if health<maxHealth*(3-spinIndex)/4.0:
		spinIndex+=1
		var tween=get_tree().create_tween()
		tween.tween_property(self,"spinSpeed",spinSpeeds[spinIndex],5)
		if spinIndex==3:
			$Timer.start(4)
		pattern=0
	super(delta)

func shoot1():
	const speed=300.0
	if spinSpeed==0:
		spin+=randf_range(0,2*PI)
	spin+=spinSpeed
	shoot(Vector2.from_angle(spin*2*PI)*speed)
func shoot(dir):
	var newBullet=bullet.instantiate()
	newBullet.init(position,dir,owner2,team,5,1,1)
	newBullet.name=str(randi())
	get_tree().get_nodes_in_group("level")[0].add_child(newBullet)
func spawnEnemy():
	var e=enemy.instantiate()
	e.init2(position,Vector2.from_angle(randf_range(0,2*PI))*200,owner2,team)
	e.name=str(randi())
	get_tree().get_nodes_in_group("level")[0].add_child(e)


func _on_timer_timeout():
	if !is_multiplayer_authority():
		return
	if 3<=spinIndex&&spinIndex<11:
		var tween=get_tree().create_tween()
		spinIndex+=1
		tween.tween_property(self,"spinSpeed",spinSpeeds[spinIndex],2)
		return
	pattern+=1
	$Timer.start(30)
	if pattern==2:
		var cnt=randi_range(4,8)
		for i in range(cnt):
			spawnEnemy()
	elif pattern>=3:
		pattern=3	
		
		
