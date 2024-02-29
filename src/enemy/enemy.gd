class_name Enemy
extends Node3D

@onready var killed_event : TimeEvent = $TimeEvent

func _ready():
	killed_event.player_transform = global_transform
	killed_event.objective = "KILL"

func get_time_event() -> TimeEvent:
	return killed_event

func on_hit():
	killed_event.on_complete()
