extends TrackingProjectile
class_name Character
@export var score=0

func _ready():
	owner2=self
	super()

func takeDamage(d,source=null):
	super(d)
	if health<0:
		if source:
			source.onKill(self)
		die()
func onKill(victim):
	Global.onKill.emit(self,victim)
