extends Projectile
var explosion=load("res://scenes/projectiles/Explosion.tscn")

func takeDamage(a,b=null):
	var e=explosion.instantiate()
	e.init(position,Vector2.ZERO,owner2,team,0.2,damage/5.0,1000)
	e.init2(100)
	e.name=str(randi())+"e"
	Global.spawnObject.emit(e)
	if b.health>damage:
		health=0
	super(a,b)
