class_name Projectile
extends Area2D


@export var damage = 1 
@export var maxHealth = 10 
@export var team=0
var owner2
@export var health = 0
var velocity
var lifeSpan

@export var baseAcceleration=0
@export var baseSpeed=400
var speed
var acceleration=0
var accelerationDir=Vector2.ZERO
var regen=0

func _init():
	super._init()
	position=Vector2.ZERO
	velocity=Vector2.ZERO
	team=0
	lifeSpan=-1000000
	
func init(_position=Vector2.ZERO,_velocity=Vector2.ZERO,_owner2=null,_team=0,_lifeSpan=-1000000,_damage=0,_maxHealth=1):
	position=_position
	velocity=_velocity
	owner2=_owner2
	team=_team
	lifeSpan=_lifeSpan
	damage=_damage
	maxHealth=_maxHealth
	health=maxHealth

# Called when the node enters the scene tree for the first time.
func _ready():	
	reset()
func _process(delta): # need this for inherited classes
	pass

func reset():
	health=maxHealth
		
func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	resetStats()
	_physics_process2(delta)
	if acceleration>0:
		velocity+=accelerationDir*acceleration*delta
		if velocity.length() > speed:
			velocity = velocity.normalized() * speed
	if regen>0:
		health+=regen*delta
		health=min(health,maxHealth)
	
	if health<=0:
		die()
		return
	position+=velocity * delta;
	lifeSpan-=delta
	if lifeSpan<=0&&lifeSpan>-1000000:
		die()
func resetStats():
	speed=baseSpeed
	acceleration=baseAcceleration
	regen=0
func _physics_process2(_delta):
	pass
func _on_area_entered(area):
	if !is_multiplayer_authority():
		return
	if team==area.get("team"):
		return
	if area.get("damage")==null:
		return
	takeDamage(area.get("damage"),area.get("owner2"))
func _on_area_exited(_area):
	pass

func takeDamage(d,_source=null):
	health-=d
func onKill(_victim):
	pass

func die():
	queue_free()
	die_client.rpc()

@rpc("authority") func die_client():
	queue_free()

