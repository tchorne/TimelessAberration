extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_proceed_button_pressed():
	LevelManager.next_level()

func _on_retry_button_pressed():
	LevelManager.restart()
