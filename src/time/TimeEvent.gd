class_name TimeEvent
extends Node

@export var transform_target : Node3D

signal completed
signal begun

var objective: String = ""
var player_transform: Transform3D

func _ready():
	if is_instance_valid(transform_target):
		player_transform = transform_target.global_transform

func complete():
	completed.emit()
	
func begin():
	begun.emit()
