extends Character
var bullet=load("res://scenes/projectiles/projectile_small.tscn")
var dash
var energy=9999

var targetPos
@export var baseFollowDistance=500
var followDistance=0
var dodgeDistance=80
var pattern=0
var incoming=[]

func _ready():
	owner2=self
	dash=load("res://scenes/abilities/dash.tscn").instantiate()
	dash.bearer=self
	score=1
	super()

func resetStats():
	followDistance=baseFollowDistance
	super()

func _physics_process2(delta):
	if !is_multiplayer_authority():
		return
	dash.updateTimer(delta)
	dash.doEffect()
	if target:
		targetPos=target.position
	else:
		targetPos=position
	var bestScore = -999;
	var bestDist = 99999;
	var bestVector;
	var scores = [];
	for i in range(0,9):
		var dir=Vector2.ZERO if i==0 else Vector2.from_angle(PI*2/8*i)*speed*delta
		var newPos=position+dir
		var score=0.7
		for p in incoming:
			if p.velocity.length()>0:
				var a = p.velocity.dot(newPos - p.position) / p.velocity.length()
				var b = (newPos - p.position - a * p.velocity.normalized()).length();
				if b < dodgeDistance && a > 0:
					var score2 = a / p.velocity.length() - (dodgeDistance - b) / speed * 2;
					score=min(score,score2)
			if newPos.distance_to(p.position)<dodgeDistance:
				score=min(score,-(dodgeDistance-newPos.distance_to(p.position))/speed/2)
		scores+= [score];
		bestScore = max(bestScore, score)
	if bestScore<0.05:
		dash.attemptAbility(null)
	for i in range(0,9):
		var dir=Vector2.ZERO if i==0 else Vector2.from_angle(PI*2/8*i)*speed*delta
		var newPos=position+dir
		if scores[i]>=bestScore-delta*0.1:
			if position.distance_to(targetPos)<followDistance&&i==0:
				bestScore=999
				bestVector=dir
			elif newPos.distance_to(targetPos)<bestDist:
				bestDist=newPos.distance_to(targetPos)
				bestVector=dir
	accelerationDir=bestVector.normalized()
	var vp=velocity.dot(accelerationDir)*accelerationDir
	velocity-=(velocity-vp)*(1-0.5**(delta/0.1))
	super(delta)

func shoot(dir):
	var newBullet=bullet.instantiate()
	newBullet.init(position,dir,owner2,team,5,1,1)
	newBullet.name=str(randi())
	Global.spawnObject.emit(newBullet)

func _on_timer_timeout():
	if !is_multiplayer_authority():
		return
	if !target:
		return
	const speed=700.0
	var t=0.0
	for i in range(2,-5,-1):
		var t1=t+2.0**i
		var newPos=targetPos+target.velocity*t1
		if (newPos-position).length()/speed>=t1:
			t=t1
	t=randf_range(-0.2,t)
	var dir=(targetPos+target.velocity*t-position).normalized()*speed
	shoot(dir)
		
		
func _on_targeting_area_entered(area):
	if !is_multiplayer_authority():
		return
	if team!=area.get("team")&&!area.get("spectator")&&area.get("damage")&&area.get("damage")>0:
		incoming+=[area]
	super(area)

	

func _on_targeting_area_exited(area):
	incoming.erase(area)

