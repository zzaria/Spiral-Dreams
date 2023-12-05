extends Projectile
var delayedLaunchProjectile

func init2(_position,dir,proj):
	position=_position
	rotation=dir.angle() 
	delayedLaunchProjectile=proj
func die():
	Global.spawnObject.emit(delayedLaunchProjectile)
	super()

