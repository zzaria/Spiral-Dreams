extends Level_Base

func _on_button_pressed():
	changeLevel.emit("level_select")
