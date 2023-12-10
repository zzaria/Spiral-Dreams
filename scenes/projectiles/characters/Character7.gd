extends Character

var targetPos
@export var followDistance=100
@export var jumpDistance=150
var inJumpRange=false
var jumping=false
@export var initialJumpDelay=1.0
@export var jumpDelay=3.0
@export var jumpDuration=0.1
var jumpSpeed

func _ready():
	jumpSpeed=2.0*followDistance/jumpDuration
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
	targetPos=target.position if target else null
	if targetPos:
		if !jumping:
			if (targetPos-position).length()>followDistance:
				velocity=(targetPos-position).normalized()*speed
			else:
				velocity=Vector2.ZERO
			if (targetPos-position).length()<jumpDistance:
				if !inJumpRange:
					$Timer.start(initialJumpDelay)
				inJumpRange=true
			else:
				if inJumpRange:
					$Timer.stop()
				inJumpRange=false
	else:
		velocity=Vector2.ZERO

	super(delta)



func _on_timer_timeout():
	if !is_multiplayer_authority():
		return
	if jumping:
		jumping=false
		$Timer.start(jumpDelay-jumpDuration)
	else:
		if !targetPos:
			return
		jumping=true
		$Timer.start(jumpDuration)
		velocity=(targetPos-position).normalized()*jumpSpeed
