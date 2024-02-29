extends Sprite2D

@onready var killed_event: TimeEvent = $Killed

func _ready():
	killed_event.player_position = position
