class_name TimeEvent
extends Node

signal completed

var objective: String = ""
var player_transform: Transform3D

func complete():
	completed.emit()
