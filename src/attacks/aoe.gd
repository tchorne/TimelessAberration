extends Area3D

@onready var collision_shape_3d = $CollisionShape3D
@onready var fire = $fire
@onready var bottle = $bottle

var velocity := Vector3.UP*-1

var phy_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var falling := true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var delta2 = delta*GlobalSettings.game_speed
	if falling:
		velocity.y -= phy_gravity * delta2
		translate(velocity*delta2)


func _on_area_3d_2_body_entered(body):
	fire.visible = true
	bottle.visible = false
	falling = false
	
