class_name Enemy
extends Node3D

@onready var killed_event : TimeEvent = $TimeEvent
@onready var mesh : MeshInstance3D = $human_autorig/metarig/Skeleton3D/male
@onready var static_body_3d = $StaticBody3D

func _ready():
	killed_event.player_transform = global_transform
	killed_event.objective = "KILL"
	GlobalEventBus.connect("enemy_selected", on_enemy_selected)
	GlobalEventBus.connect("new_event_begun", on_other_event_begun)
	killed_event.begun.connect(on_event_begun)

func get_time_event() -> TimeEvent:
	return killed_event

func on_hit():
	killed_event.complete()

func on_enemy_selected(e: Enemy):
	if self == e:
		mesh.set_instance_shader_parameter("lines", true)
	else:
		mesh.set_instance_shader_parameter("lines", false)

func on_event_begun():
	static_body_3d.set_collision_layer_value(2, true)
	mesh.set_instance_shader_parameter("targetable", true)

func on_other_event_begun():
	static_body_3d.set_collision_layer_value(2, false)
	mesh.set_instance_shader_parameter("targetable", false)
	pass
