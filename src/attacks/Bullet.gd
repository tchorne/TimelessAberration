extends Node3D

var speed = 10.0

func _process(delta):
	global_position += -global_transform.basis.z * delta * speed
