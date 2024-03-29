extends Node

#@export var enemy_list: Array[Enemy]
#@export var enemy_time_ordered: Array[Enemy]

const TIME_BETWEEN_EVENTS = 0.4
const OBJECTIVE_PACKED = preload("res://src/time/objective_indicator.tscn")

## Event order from player perspective 
var event_list: Array[TimeEvent] = []
@export var last_event: TimeEvent
## Event order fro game perspective
var time_ordered: Array[TimeEvent] = []

@onready var replay_controller = ReplayController
@onready var player = get_tree().get_first_node_in_group('player')
@onready var animation_player = $AnimationPlayer
@onready var ui = get_tree().get_first_node_in_group("ui")

var event_index = 0
var time_index = 0
var frames_since_event_start = 0
var time_between_events = 0.2

var objective_time: float = 10000.0
var time_remaining: float = 100.0


var current_time = 0 # Most recent call to player_packet.get_realtime_frame()
var current_event : TimeEvent

@export var objective_mat: ShaderMaterial


var objective_object : Node3D


func init():
	#for e in enemy_list:
	#	event_list.append(e.get_time_event())
	#for e in enemy_time_ordered:
	#	time_ordered.append(e.get_time_event())
	GlobalMusic.toggle_muffle(false)
	time_ordered.clear()
	get_tree().get_first_node_in_group("ui").set_cctv(false)

	for e in get_tree().get_nodes_in_group("TimeEvents"):
		if e.is_queued_for_deletion(): 
			continue
		assert(e is TimeEvent, "Non-TimeEvent in TimeEvents group")
		time_ordered.append(e)
		e.connect("completed", next_event)
		
	event_list = time_ordered.duplicate()
	event_list.sort_custom(TimeEvent.compare)
	
	for e in get_tree().get_nodes_in_group("last_event"):
		if not e.is_queued_for_deletion():
			last_event = e
	
	event_list.append(last_event)
	time_ordered.append(last_event)
	last_event.connect("completed", end_level)
	
	if is_instance_valid(objective_object):
		objective_object.queue_free()
		
	objective_object = null
	animation_player.stop()
	player.init()
	
	event_index = 0
	next_event()

func _process(delta):
	var delta2 = delta*GlobalSettings.game_speed
	if GlobalSettings.game_active and not player.invincible:
		time_remaining -= delta2
	ui.set_time_remaining(time_remaining/objective_time)
	if time_remaining < 0: LevelManager.restart()
	
func next_event():
	frames_since_event_start = 0
	var next : TimeEvent = event_list[event_index]
	current_event = next
	assert(next.player_transform.origin != Vector3.ZERO)
	event_index += 1
	objective_time = next.time
	time_remaining = next.time
	
	player.global_transform = next.player_transform
	var time_ordered_pos = time_ordered.find(next)
	time_index = time_ordered_pos + 1
	
	GlobalEventBus.new_event(ReplayController.get_realtime_frame())
	next.begin()
	animation_player.play("eventstart")
	
	assert(time_ordered_pos != -1, "Event not in time ordered")
	for i in range(time_ordered.size()):
		#time_ordered[i].get_parent().visible = i >= time_ordered_pos
		pass
		#if i == time_index:
		#	time_ordered[i].get_parent().modulate = Color.BLUE
		#else:
		#	time_ordered[i].get_parent().modulate = Color.BLACK
	

func end_level():
	GlobalMusic.toggle_muffle(true)
	GlobalSettings.game_active = false
	get_tree().get_first_node_in_group("replay_cam").current = true
	ui.set_cctv(true)
	player.invincible = true
	player.invincibility_timer.stop()
	ReplayController._on_player_level_finished()
	pass

func new_frame():
	frames_since_event_start += 1

## Returns frames since event start
func get_frame():
	return frames_since_event_start
	
func create_objective():
	objective_object = OBJECTIVE_PACKED.instantiate()
	add_child(objective_object)
	objective_object.global_position = current_event.objective_position
	$Label.text = "[p align=center][shake]" + current_event.objective

func destroy_objective():
	if is_instance_valid(objective_object):
		objective_object.queue_free()


