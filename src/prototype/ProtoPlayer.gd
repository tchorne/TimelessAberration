extends Sprite2D

@onready var area_2d = $Area2D
@onready var crosshair = $Crosshair
@onready var time_manager = $"../TimeManager"

signal level_finished

const SPEED = 200
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	position += delta * SPEED * direction
	
	var enemies_in_range : Array[Area2D] = area_2d.get_overlapping_areas()
	var closest_enemy = null
	var dist := 10000000.0
	for enemy in enemies_in_range:
		var d = global_position.distance_to(enemy.global_position)
		if d < dist:
			closest_enemy = enemy
			dist = d
	
	if closest_enemy:
		crosshair.global_position = closest_enemy.global_position
	#print(closest_enemy)
	
	if closest_enemy and Input.is_action_just_pressed("ui_accept"):
		time_manager.next_event()


func _on_end_collider_area_entered(_area):
	level_finished.emit()
	pass # Replace with function body.
