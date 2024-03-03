class_name TimeEvent
extends Node

@export var transform_target : Node3D
@export var priority = -1
@export var objective_position_node : Node3D


signal completed
signal begun

var objective: String = ""
var player_transform: Transform3D
var objective_position: Vector3

func _ready():
	if is_instance_valid(transform_target):
		player_transform = transform_target.global_transform
	if is_instance_valid(objective_position_node):
		objective_position = objective_position_node.global_position
	else:
		objective_position = get_parent().global_position

func complete():
	completed.emit()
	
func begin():
	begun.emit()

static func compare(a: TimeEvent, b: TimeEvent):
	return b.priority > a.priority
