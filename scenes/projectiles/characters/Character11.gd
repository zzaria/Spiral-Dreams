extends Character

@export var spawnList: Array[PackedScene]

var targetPos
@export var followDistance=900
@export var avoidDistance=350
var incoming=[]
var bestDir

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
	targetPos=target.position if target else null

	bestDir=[0,Vector2.ZERO]
	if targetPos:
		if (targetPos-position).length()>followDistance:
			var dir=(targetPos-position).normalized()*speed
			calcScore(dir)
	for i in range(0,9):
		var dir=Vector2.ZERO if i==0 else Vector2.from_angle(PI*2/8*i)*speed*delta
		calcScore(dir)
	velocity=bestDir[1].normalized()*speed
	super(delta)

func calcScore(dir):
	var newPos=position+dir
	var score=avoidDistance
	for p in incoming:
		if p&&is_instance_valid(p):
			score=min(score,newPos.distance_to(p.position))
	if score>bestDir[0]:
		bestDir=[score,dir]
	return score
	
func _on_targeting_area_entered(area):
	if !is_multiplayer_authority():
		return
	if team!=area.get("team")&&!area.get("spectator")&&area.get("damage")&&area.get("damage")>0:
		incoming+=[area]
	super(area)

	

func _on_targeting_area_exited(area):
	incoming.erase(area)
	


func _on_timer_2_timeout():
	if !is_multiplayer_authority():
		return
	if !targetPos:
		return
	var minion=spawnList.pick_random().instantiate()
	minion.init2(position,team,owner2)
	Global.spawnObject.emit(minion)
