extends Projectile
var explosion=load("res://scenes/projectiles/Explosion.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func takeDamage(a,b=null):
	var e=explosion.instantiate()
	e.init(position,Vector2.ZERO,owner2,team,0.2,damage/5,1000)
	e.init2(100)
	e.name=str(randi())+"e"
	self.get_tree().get_nodes_in_group("level")[0].add_child(e)
	if b.health>damage:
		health=0
	super(a,b)
