extends Node
func _ready():
	Global.level=$MainMenu
	Global.changeLevel.connect(changeLevel)


func changeLevel(newLevel=null):
	print_debug(newLevel)
	if Global.level:
		Global.level.queue_free()
	if newLevel:
		newLevel=load("res://scenes/levels/"+newLevel+".tscn").instantiate()
		Global.level=newLevel
		add_child(newLevel)
	else:
		Global.level=null


