extends Control

@onready var crosshair = $Crosshair
@onready var cctv = $CCTV
@onready var end_screen = $EndScreen
@onready var time_remaining = %TimeRemaining

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_time_remaining(val):
	time_remaining.value = val
	
func set_cctv(val):
	if val:
		cctv.visible = true
		end_screen.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	else:
		cctv.visible = false
		end_screen.visible = false
