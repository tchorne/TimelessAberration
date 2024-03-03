extends Node

const LEVEL_ORDER = [
	"res://src/stages/stage_2.tscn"
]

var current_level_index = 0
var current_level : Node

var world_node : Node


func _ready():
	if get_tree().current_scene.name == 'Main':
		print("main")
		world_node = get_tree().root.find_child("world", true, false)
		load_stage(LEVEL_ORDER[0])
	else:
		print("specific")
		
func load_stage(stage: String):
	var instance : Node3D = load(stage).instantiate()
	if is_instance_valid(current_level):
		current_level.queue_free()
		for event in get_tree().get_nodes_in_group("TimeEvents"):
			event.queue_free()
	ReplayController.reset()
	
		
	instance.ready.connect(begin_stage)
	
	world_node.add_child(instance)
	
	current_level = instance
	
func begin_stage():
	world_node.get_node("TimeManager").init()
	
func _input(event):
	if event.is_action_pressed("restart"):
		restart()

func restart():
	load_stage(LEVEL_ORDER[current_level_index])
