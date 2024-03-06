extends Node

signal music_changed(title: String)

var currently_playing_string = "Vitalezzz - A Flawless Getaway"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func toggle_muffle(val):
	AudioServer.set_bus_effect_enabled(0, 0, val)
	AudioServer.set_bus_effect_enabled(0, 1, val)
	pass
