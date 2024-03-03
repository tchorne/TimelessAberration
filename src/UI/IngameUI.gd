extends Control

@onready var crosshair = $Crosshair
@onready var cctv = $CCTV


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_cctv(val):
	if val:
		cctv.visible = true
	else:
		cctv.visible = false
