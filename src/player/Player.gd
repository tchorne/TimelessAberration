extends CharacterBody3D

signal replayable_action_performed(Callable)

# Player nodes

@onready var neck = $Neck
@onready var head = $Neck/Head
@onready var standing_collision_shape = $StandingCollisionShape
@onready var crouching_collision_shape = $CrouchingCollisionShape
@onready var ray_cast_3d = $CeilingCast
@onready var eyes = $Neck/Head/Eyes
@onready var camera_3d = $Neck/Head/Eyes/Camera3D
@onready var interact = $Neck/Head/Eyes/Camera3D/Interact
@onready var kill_animation_player = $KillAnimation/KillAnimationPlayer

# Sword nodes

@onready var sword_animation_player = $Neck/SwordPivot/AnimationPlayer
@onready var enemy_attack_detector = $EnemyAttackDetector


# TEMP time variables

@onready var time_manager = $"../TimeManager"

# Sound variables
@onready var sound_death = %SoundDeath
@onready var sound_run = $Sounds/SoundRun
@onready var sound_slice = %SoundSlice

var my_velocity := Vector3.ZERO

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

# Free look variables

var free_looking := false
var free_look_tilt = 6

# Movement variables

var jump_velocity = 4.5
var crouching_depth := -0.5
var lerp_speed = 10.0

# Air control variables

var launch_momentum := Vector3.ZERO

# Sword boost variables

var sword_boost_speed_max = 7.0
var sword_boost_speed = 0.0
var sword_boost_decay = 15
var sword_boost_direction := Vector3.FORWARD

# Input variables 
var direction := Vector3.ZERO
var mouse_sens = 0.3

var highlighted_enemy: Enemy
var time_since_jump = 0.0

var enemy_being_killed : Node
@export var distance_to_enemy : float = 0
var position_before_attack: Vector3

@export var invincible: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-65), deg_to_rad(65))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	
func _physics_process(delta):
	
	var delta2 = GlobalSettings.game_speed * delta
	
	calculate_movement(delta2)
	
	if Input.is_action_just_pressed("primary"):
		sword_animation_player.play("swing")
		sword_boost_direction = -head.global_transform.basis.z.normalized()
		sword_boost_speed = sword_boost_speed_max
		my_velocity.y += (sword_boost_direction * sword_boost_speed).y * 0.2
		if is_instance_valid(highlighted_enemy) and not is_instance_valid(enemy_being_killed):
			enemy_being_killed = highlighted_enemy
			position_before_attack = global_position
			kill_animation_player.play("kill")
			
	if (position_before_attack != null and is_instance_valid(enemy_being_killed) and distance_to_enemy > 0):
		global_position = position_before_attack.lerp(enemy_being_killed.global_position, distance_to_enemy)
		
	if interact.is_colliding():
		var e: Enemy = interact.get_collider().get_parent()
		if highlighted_enemy != e:
			GlobalEventBus.select_enemy(e)
			highlighted_enemy = e
	else:
		if is_instance_valid(highlighted_enemy):
			highlighted_enemy = null
			GlobalEventBus.select_enemy(null)
	
	velocity = my_velocity * GlobalSettings.game_speed
	move_and_slide()
	my_velocity = velocity / GlobalSettings.game_speed
	
	process_sounds()

func process_sounds():
	sound_run.stream_paused = not (is_on_floor() and direction.length() > 0.2 and not sliding)

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
		free_looking = true
		slide_timer -= delta
		if slide_timer < 0:
			sliding = false
			free_looking = false
	else: 
		free_looking = false
	
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
		time_since_jump += delta
		my_velocity.y -= gravity * delta
		if Input.is_action_just_pressed("crouch"):
			if my_velocity.y > 0: my_velocity.y = 0
		if Input.is_action_pressed("crouch") and time_since_jump > 0.2:
			my_velocity.y -= gravity*delta*3
	else:
		launch_momentum = Vector3.ZERO
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and !ray_cast_3d.is_colliding():
		my_velocity.y = jump_velocity
		launch_momentum = Vector3(my_velocity.x, 0, my_velocity.z) * 0.2 * (1.5 if sliding else 1.0)
		sliding = false
		time_since_jump = 0.0
	
	if not Input.is_action_pressed("crouch"):
		sliding = false


	# Free look camera
	if not free_looking:
		
		var diff = lerp(neck.rotation.y, 0.0, delta*lerp_speed) - neck.rotation.y
		if (diff > abs(neck.rotation.y)):
			neck.rotation.y = 0
			diff = 0
		
		rotate_y(-diff)
		neck.rotation.y += diff
		
	# Slide camera
	if sliding:
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, -deg_to_rad(3.5+neck.rotation.y*free_look_tilt), delta*lerp_speed) 
	else:
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, 0.0, delta*lerp_speed)
	

	
	direction = lerp(direction, transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized(), delta*lerp_speed)
	if sliding: 
		direction = transform.basis * Vector3(slide_vector.x, 0, slide_vector.y).normalized()
	
	if direction:
		my_velocity.x = direction.x * current_speed
		my_velocity.z = direction.z * current_speed
		
		if sliding:
			my_velocity.x = direction.x * (slide_timer+0.1) * slide_speed
			my_velocity.z = direction.z * (slide_timer+0.1) * slide_speed
			
	else:
		my_velocity.x = 0
		my_velocity.z = 0
	
	if not is_on_floor():
		#my_velocity.x *= 0.5
		#my_velocity.z *= 0.5
		pass
	
	my_velocity += launch_momentum*0.5
	
	sword_boost_speed = move_toward(sword_boost_speed, 0, sword_boost_decay*delta)
	#my_velocity.x += (sword_boost_direction * sword_boost_speed).x
	#my_velocity.z += (sword_boost_direction * sword_boost_speed).z
	
	pass

func get_animation() -> String:
	if sliding: return "slide"
	if crouching: pass # return "crouch"
	if not is_on_floor(): return "jump"
	if direction.length_squared() < 0.01: pass # return "idle"
	return "run"

func kill_and_teleport():
	replayable_action_performed.emit(enemy_being_killed.animate_death)
	enemy_being_killed.on_hit()
	enemy_being_killed = null
	
	
func _on_bullet_hurt_box_area_entered(area):
	if !invincible:
		sound_death.play()
		LevelManager.restart()
