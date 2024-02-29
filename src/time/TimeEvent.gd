class_name TimeEvent
extends Node

signal complete

var objective: String = ""
var player_transform: Transform3D

func on_complete():
	complete.emit()
