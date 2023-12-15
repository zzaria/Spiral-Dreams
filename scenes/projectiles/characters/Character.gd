extends TrackingProjectile
class_name Character
@export var score=0

func _ready():
	owner2=self
	super()
func init2(_position,_team,_owner2=null):
	position=_position
	team=_team
	if owner2:
		owner2=_owner2
		team=owner2.team

func takeDamage(d,source=null):
	super(d)
	if health<=0:
		if source:
			source.owner2.onKill(self)
		die()
func onKill(victim):
	Global.onKill.emit(self,victim)
