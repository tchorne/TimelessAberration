extends CharacterBody3D

# Player nodes

@onready var neck = $Neck
@onready var head = $Neck/Head
@onready var standing_collision_shape = $StandingCollisionShape
@onready var crouching_collision_shape = $CrouchingCollisionShape
@onready var ray_cast_3d = $RayCast3D
@onready var eyes = $Neck/Head/Eyes
@onready var camera_3d = $Neck/Head/Eyes/Camera3D

# Sword nodes

@onready var sword_animation_player = $SwordPivot/AnimationPlayer

#Speed variables

var current_speed = 5.0

const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0

# States

var walking = false
var sprinting = false
var crouching = false
var sliding = false

# Slide vars

var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector := Vector2.ZERO
var slide_speed = 10.0

# Head bobbing vars

const head_bobbing_sprinting_speed = 18.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0

const head_bobbing_sprinting_intensity = 0.15
const head_bobbing_walking_intensity = 0.1
const head_bobbing_crouching_intensity = 0.05

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0


# Movement variables

var jump_velocity = 4.5
var crouching_depth := -0.5
var lerp_speed = 10.0

# Air control variables

var launch_momentum := Vector3.ZERO

# Input variables 
var direction := Vector3.ZERO
var mouse_sens = 0.3


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		if not sliding:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	
func _physics_process(delta):
	
	
	move_and_slide()

func calculate_movement(delta):
	# Getting movement input
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	# Handle movement state
	
	# Crouching
	if (Input.is_action_pressed("crouch") || sliding) and is_on_floor():
		current_speed = crouching_speed
		neck.position.y = lerp(neck.position.y, 1.8+crouching_depth, delta*lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		# Slide begin logic
		if sprinting and input_dir != Vector2.ZERO:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
		
		walking = false
		sprinting = false
		crouching = true
			
	elif !ray_cast_3d.is_colliding():
		
		# Standing
		
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		neck.position.y = lerp(neck.position.y, 1.8, delta*lerp_speed)
		
		if not Input.is_action_pressed("sprint"):
			# Sprinting
			current_speed = sprinting_speed
			walking = false
			sprinting = true
			crouching = false
		
		else:
			# Walking
			current_speed = walking_speed
			walking = true
			sprinting = false
			crouching = false
	
	# Handle sliding
	
	if sliding:
		slide_timer -= delta
		if slide_timer < 0:
			sliding = false
	
	# Handle headbob
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed*delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed*delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed*delta
	
	if is_on_floor() && !sliding && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)*0.5
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*head_bobbing_current_intensity/2, delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*head_bobbing_current_intensity, delta*lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta*lerp_speed)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		launch_momentum = Vector3.ZERO
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !ray_cast_3d.is_colliding():
		velocity.y = jump_velocity
		launch_momentum = Vector3(velocity.x, 0, velocity.z) * 0.2 * (1.5 if sliding else 1.0)
		sliding = false
	
	if not Input.is_action_pressed("crouch"):
		sliding = false

	# Slide camera
	if sliding:
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, -deg_to_rad(3.5), delta*lerp_speed)
	else:
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, 0.0, delta*lerp_speed)
	
	direction = lerp(direction, transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized(), delta*lerp_speed)
	if sliding: 
		direction = transform.basis * Vector3(slide_vector.x, 0, slide_vector.y).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if sliding:
			velocity.x = direction.x * (slide_timer+0.1) * slide_speed
			velocity.z = direction.z * (slide_timer+0.1) * slide_speed
			
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	if not is_on_floor():
		velocity.x *= 0.5
		velocity.z *= 0.5
	velocity += launch_momentum*1.5
	pass