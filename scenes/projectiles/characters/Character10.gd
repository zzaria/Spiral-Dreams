extends Character

@export var spawnList: Array[PackedScene]

var targetPos
@export var followDistance=700
@export var jumpDistance=150
var inJumpRange=false
var jumping=false
@export var initialJumpDelay=1.0
@export var jumpDelay=3.0
@export var jumpDuration=0.1
var jumpProgress
var originalPosition

func _ready():
	super()
func init2(_position,_team,_owner2=null):
	position=_position
	team=_team
	if owner2:
		owner2=_owner2
		team=owner2.team

func _physics_process2(delta):
	if !is_multiplayer_authority():
		return
	
	velocity=Vector2.ZERO
	if jumping:
		jumpProgress+=delta
		var x=jumpProgress/(jumpDuration/2) if jumpProgress<(jumpDuration/2) else (jumpDuration/2)-jumpProgress
		position=targetPos*x+originalPosition*(1-x)
		if jumpProgress>=jumpDuration:
			position=originalPosition
			jumping=false
	if !jumping:
		targetPos=target.position if target else null
		if targetPos:
			if (targetPos-position).length()>followDistance:
				velocity=(targetPos-position).normalized()*speed
			if (targetPos-position).length()<jumpDistance:
				if !inJumpRange:
					$Timer.start(initialJumpDelay)
				inJumpRange=true
			else:
				if inJumpRange:
					$Timer.stop()
				inJumpRange=false

	super(delta)



func _on_timer_timeout():
	if !is_multiplayer_authority():
		return
	if !targetPos:
		return
	if !jumping:
		if !targetPos:
			return
		jumping=true
		jumpProgress=0
		originalPosition=position
		$Timer.start(jumpDelay)


func _on_timer_2_timeout():
	if !is_multiplayer_authority():
		return
	if !targetPos:
		return
	var minion=spawnList.pick_random().instantiate()
	minion.init2(position,team,owner2)
	Global.spawnObject.emit(minion)
