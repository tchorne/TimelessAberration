extends Sprite2D

@onready var killed_event: TimeEvent2D = $Killed

func _ready():
	killed_event.player_position = position
