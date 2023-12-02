extends Projectile
var delayedLaunchProjectile

func init2(_position,dir,proj):
	position=_position
	rotation=dir.angle() 
	delayedLaunchProjectile=proj
func die():
	self.get_tree().get_nodes_in_group("level")[0].add_child(delayedLaunchProjectile)
	super()

