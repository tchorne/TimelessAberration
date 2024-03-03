extends Node

var game_speed = 1.0

func update_game_speed(val: float):
	game_speed = val

func _input(event):
	if event.is_action_released("fullscreen"):
		toggle_fullscreen()
		
func toggle_fullscreen():
	if get_window().mode == Window.MODE_WINDOWED:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
