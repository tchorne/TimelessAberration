extends Node

## Event order from player perspective 
@export var event_list: Array[TimeEvent]

## Event order fro game perspective
@export var time_ordered: Array[TimeEvent]

@onready var player = $"../Player"

var event_index = 0
var time_index = 0
var frames_since_event_start = 0
var time_between_events = 0.2

func _ready():
	for i in range(time_ordered.size()):
		if i == time_index:
			time_ordered[i].get_parent().modulate = Color.BLUE
		else:
			time_ordered[i].get_parent().modulate = Color.BLACK
			
func next_event():
	frames_since_event_start = 0
	var next : TimeEvent = event_list[event_index]
	event_index += 1
	player.global_position = next.player_position
	
	var time_ordered_pos = time_ordered.find(next)
	time_index = time_ordered_pos + 1
	assert(time_ordered_pos != -1, "Event not in time ordered")
	for i in range(time_ordered.size()):
		time_ordered[i].get_parent().visible = i > time_ordered_pos

		if i == time_index:
			time_ordered[i].get_parent().modulate = Color.BLUE
		else:
			time_ordered[i].get_parent().modulate = Color.BLACK
		
func new_frame():
	frames_since_event_start += 1

func get_frame():
	return frames_since_event_start
	
