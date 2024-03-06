class_name Bullet
extends Node3D

var speed = 20.0

func _process(delta):
	var delta2 = GlobalSettings.game_speed * delta
	global_position += -global_transform.basis.z * delta2 * speed
