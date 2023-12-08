extends Projectile
class_name TeamSpawn

signal dead(team:int)
var healthEnabled=false

func _ready():
	owner2=self
	super()

func takeDamage(d,source=null):
	if !healthEnabled:
		return
	super(d,source)
	if health<0:
		if source:
			source.onKill(self)
		die()

func die():
	dead.emit(team)
	super()

func onKill(victim):
	Global.onKill.emit(self,victim)
