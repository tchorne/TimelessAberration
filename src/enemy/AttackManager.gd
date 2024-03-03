class_name AttackManager
extends Node

const BULLET = preload("res://src/attacks/bullet.tscn")

enum AttackType { GUN, TRIPLEGUN, MACHINEGUN, AOE, SHIELD }

@onready var animation_player = $AnimationPlayer
@onready var gun_origin = %GunOrigin
@onready var attack_area = %AttackArea


var player: CharacterBody3D
var player_position: Vector3
var player_velocity: Vector3

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _process(delta):
	var delta2 = GlobalSettings.game_speed * delta
	animation_player.advance(delta2)
	
func begin_attack(type: AttackType):
	if animation_player.is_playing(): return
	
	ReplayController.add_callable(fake_begin_attack.bind(type))
	match type:
		AttackType.GUN:
			animation_player.play("gun")
		AttackType.TRIPLEGUN:
			animation_player.play("triplegun")
			


func fake_begin_attack(type: AttackType):
	if animation_player.is_playing(): return
	
	match type:
		AttackType.GUN:
			animation_player.play("fake_gun")
		AttackType.TRIPLEGUN:
			animation_player.play("fake_gun")

func get_player_position():
	player_position = player.head.global_position
	player_velocity = player.velocity
	get_parent().look_at(Vector3(player_position.x, get_parent().global_position.y, player_position.z))
	get_parent().rotate_y(PI)
	ReplayController.add_callable(update_rotation_y.bind(get_parent().rotation.y))

func update_rotation_y(val):
	get_parent().rotation.y = val

func fire_bullet():
	var b = BULLET.instantiate()
	add_child(b)
	b.global_position = gun_origin.global_position
	b.look_at(player_position+player_velocity*0.15)
	ReplayController.add_callable(fire_replay_bullet.bind(player_position+player_velocity*0.15))	
	
func fire_replay_bullet(pos: Vector3):
	if get_parent().dead: return
	var b = BULLET.instantiate()
	add_child(b)
	b.global_position = gun_origin.global_position
	b.look_at(pos)


func _on_animation_player_animation_finished(anim_name):
	if not get_parent().dead and attack_area.get_overlapping_bodies().size() > 0:
		begin_attack(get_parent().attackType)
