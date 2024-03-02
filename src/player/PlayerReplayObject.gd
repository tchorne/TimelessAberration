extends Node3D

@onready var poses = $human_autorig/Poses
@onready var fade = $Fade

var usable = true

# Called when the node enters the scene tree for the first time.
func _ready():
	poses.play("run")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var delta2 = GlobalSettings.game_speed * delta
	poses.advance(delta2)
	fade.advance(delta2)
	pass

func update_animation(anim: String):
	if poses.current_animation != anim:
		poses.play("RESET")
		poses.play(anim)
		pass
		
func fade_in():
	fade.play("in")
	
func fade_out():
	fade.play("out")
