class_name TimeEvent
extends Node

@export var transform_target : Node3D
@export var priority = -1

signal completed
signal begun

var objective: String = ""
var player_transform: Transform3D

func _ready():
	if is_instance_valid(transform_target):
		player_transform = transform_target.global_transform
		print("player transform set")

func complete():
	completed.emit()
	
func begin():
	begun.emit()

static func compare(a: TimeEvent, b: TimeEvent):
	return b.priority > a.priority
