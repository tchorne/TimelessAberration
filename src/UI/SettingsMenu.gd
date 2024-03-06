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
		
	


func _on_button_pressed():
	toggle_open()


func _on_master_value_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value/200))
	
func _on_sound_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear_to_db(value/200))

func _on_music_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value/200))

func _on_alert_value_changed(value):
	AudioServer.set_bus_volume_db(3, linear_to_db(value/200))
