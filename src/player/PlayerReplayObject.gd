extends Node3D

@onready var poses = $human_autorig/Poses

# Called when the node enters the scene tree for the first time.
func _ready():
	poses.play("run")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_animation(anim: String):
	if poses.current_animation != anim:
		poses.play("RESET")
		poses.play(anim)
		pass
