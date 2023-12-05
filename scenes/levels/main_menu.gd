extends Level_Base

func _on_button_pressed():
	Global.changeLevel.emit("level_select")
