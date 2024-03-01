class_name Enemy
extends Node3D

@onready var killed_event : TimeEvent = $TimeEvent
@onready var mesh : MeshInstance3D = $human_male/Armature/Skeleton3D/male

func _ready():
	killed_event.player_transform = global_transform
	killed_event.objective = "KILL"
	GlobalEventBus.connect("enemy_selected", on_enemy_selected)

func get_time_event() -> TimeEvent:
	return killed_event

func on_hit():
	killed_event.complete()

func on_enemy_selected(e: Enemy):
	if self == e:
		mesh.set_instance_shader_parameter("lines", true)
	else:
		mesh.set_instance_shader_parameter("lines", false)
