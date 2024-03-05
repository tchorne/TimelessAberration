extends Control

var open: bool = false

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_open()
		
func toggle_open():
	if open:
		visible = false
		get_tree().paused = false
		if GlobalSettings.game_active:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		open = false
	else:
		visible = true
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		open = true
		
	
