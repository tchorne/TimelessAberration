extends Area3D

@onready var in_elevator = $InElevator


func _on_body_entered(body):
	in_elevator.complete()
