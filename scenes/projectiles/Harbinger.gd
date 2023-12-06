extends Projectile
var delayedLaunchProjectile

func init2(_position,dir,width,proj):
	position=_position
	rotation=dir.angle() 
	$ColorRect.size.y=width
	$ColorRect.position.y=-width/2
	delayedLaunchProjectile=proj
func die():
	Global.spawnObject.emit(delayedLaunchProjectile)
	super()

