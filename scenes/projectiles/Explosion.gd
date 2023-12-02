extends Projectile

func init2(size):
	$CollisionShape2D.shape.radius=size/2
	$ColorRect.size=Vector2.ONE*size
	$ColorRect.position=-Vector2.ONE*size/2
