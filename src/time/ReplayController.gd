extends Node

const UPDATE_RATE = 1.0/60.0
const TIME_BETWEEN_EVENTS = 0.2

@onready var player = get_tree().get_first_node_in_group("player")
@onready var time_manager = get_tree().root.find_child("TimeManager", true, false)
@onready var playerROs = []

var time_index_to_player_ro = {}

const PLAYER_REPLAY_OBJECT = preload("res://src/player/PlayerReplayObject.tscn")
const NUM_PLAYER_ROS = 10

class ReplayPacket:
	var object: Node3D
	var transform: Transform3D
	var animation: String = ""
	
class PlayerPacket extends ReplayPacket:
	var frames_since_event_start := 0
	var time_index := -1
	func get_start_frame():
		return int(time_index * TIME_BETWEEN_EVENTS / UPDATE_RATE)
	func get_realtime_frame():
		return get_start_frame() + frames_since_event_start
	
class ReplayFrame:
	var packets: Array[ReplayPacket]
	
class ReplayObject extends Node3D:
	var target: Node2D
	func display(packet: ReplayPacket):
		global_position = packet.position

var record_objects: Array[Node]
var replay_objects: Array[ReplayObject]

var frames: Array[ReplayFrame] = []
var player_packets: Array[PlayerPacket] = []
var time_since_last_frame = 0.0
var final_replay_frames = 1

var time_callables: Dictionary = {}

var end_index := 0
var end_playing := false


func _ready():
	#record_objects = get_tree().get_nodes_in_group("Recordable")
	for i in range(NUM_PLAYER_ROS):
		var p = PLAYER_REPLAY_OBJECT.instantiate()
		add_child(p)
		p.global_position = Vector3(0, 1000, 0)
		playerROs.append(p)
		
	player.replayable_action_performed.connect(add_callable)

func reset():
	time_callables.clear()
	frames.clear()
	player_packets.clear()
	time_callables.clear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var delta2 = GlobalSettings.game_speed * delta

	if not end_playing:
		game_process(delta2)
	else:
		end_process(delta2)

func game_process(delta):
	time_since_last_frame += delta
	if not time_since_last_frame > UPDATE_RATE: return
	
	var frame := ReplayFrame.new()
	frames.append(frame)
	record_values(frame)
	time_since_last_frame = 0.0
	
	var player_packet = PlayerPacket.new()
	player_packet.object = player
	player_packet.transform = player.global_transform
	var xz_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	if xz_velocity.length() > 0.2:
		player_packet.transform = player_packet.transform.looking_at(player.global_position - xz_velocity)
	
	time_manager.new_frame()
	display_player_packets(get_realtime_frame())
	call_replay_callables(get_realtime_frame())
	
	player_packet.frames_since_event_start = time_manager.get_frame()
	player_packet.time_index = time_manager.time_index
	player_packet.animation = player.get_animation()
	
	player_packets.append(player_packet)
	
func end_process(delta):
	time_since_last_frame += delta
	if end_index >= final_replay_frames - 1: 
		end_index = 0
		GlobalEventBus.emit_signal("final_replay_reset")
		
	if not time_since_last_frame > UPDATE_RATE: return
	time_since_last_frame = 0.0
	end_index += 1
	display_values(frames[end_index])
	call_replay_callables(end_index)
	
func record_values(frame: ReplayFrame):
	for object in record_objects:
		assert(object is Node2D, "Non-node2D in replay objects")
		var packet := ReplayPacket.new()
		packet.object = object
		packet.position = object.global_position
		frame.packets.append(packet)

func get_player_packets(realtime_frame: int) -> Array[PlayerPacket]:
	var out : Array[PlayerPacket] = []
	for packet in player_packets:
		if packet.get_realtime_frame() == realtime_frame:
			out.append(packet)
	return out
	
func display_values(frame: ReplayFrame):
	#print("displaying frame " + str(frame))
	var frame_objects = []
	
	for packet in frame.packets: frame_objects.append(packet.object)
	
	# Remove replay objects no longer in frame
	for ro_index in range(replay_objects.size() - 1, -1, -1):
		if not replay_objects[ro_index].target in frame_objects:
			replay_objects[ro_index].queue_free()
			replay_objects.remove_at(ro_index)
	
	# Add objects in frame not in replay_objects
	var replay_object_objects = []
	for ro in replay_objects: replay_object_objects.append(ro.target)
	
	for fo in frame_objects:
		if not fo in replay_object_objects:
			var new_ro = ReplayObject.new()
			add_child(new_ro)
			
			new_ro.target = fo
			if fo is Sprite2D:
				new_ro.texture = fo.texture
				new_ro.global_transform = fo.global_transform
			
			replay_objects.append(new_ro)
	
	# Map targets to their respective replay objects
	var map = {}
	for ro in replay_objects:
		map[ro.target] = ro
	
	# For each target in the frame, update the respective replay object
	for packet in frame.packets:
		var ro : ReplayObject = map[packet.object]
		ro.display(packet)

	display_player_packets(end_index)

func add_callable(c: Callable):
	var frame = get_realtime_frame()
	if frame in time_callables:
		time_callables[frame].append(c)
	else:
		time_callables[frame] = [c]
	#print("Callable added at time " + str(frame))

func call_replay_callables(frame: int):
	if frame in time_callables:
		for c in time_callables[frame]:
			c.call()

func get_realtime_frame():
	return int(time_manager.time_index * TIME_BETWEEN_EVENTS / UPDATE_RATE) + time_manager.get_frame()

func display_player_packets(frame: int):
	var i := 0
	var unused_players = time_index_to_player_ro.values()
	var unused_indices = time_index_to_player_ro.keys()
	
	for packet in get_player_packets(frame):
		var p
		if (
			not packet.time_index in time_index_to_player_ro 
			or not is_instance_valid(time_index_to_player_ro[packet.time_index])
			or not time_index_to_player_ro[packet.time_index].usable
		):
			p = PLAYER_REPLAY_OBJECT.instantiate()
			add_child(p)
			time_index_to_player_ro[packet.time_index] = p
			p.fade_in()
		
		p = time_index_to_player_ro[packet.time_index]
		#playerROs[i].global_transform = packet.transform
		#playerROs[i].update_animation(packet.animation)
		p.global_transform = packet.transform
		p.update_animation(packet.animation)
		unused_players.erase(p)
		i += 1
		
	for p in unused_players:
		if is_instance_valid(p):
			p.fade_out()
	
	#while i < playerROs.size():
	#	playerROs[i].global_position = Vector3(0, 1000, 0)
	#	i += 1
		
func _on_player_level_finished():
	#print("end playing")
	GlobalEventBus.emit_signal("final_replay_reset")
	final_replay_frames = -1
	for packet in player_packets:
		final_replay_frames = max(final_replay_frames, packet.get_realtime_frame())
	final_replay_frames += int(1.0/UPDATE_RATE)
	
	end_playing = true
	time_since_last_frame = 0.0
