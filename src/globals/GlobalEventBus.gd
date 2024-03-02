extends Node

signal enemy_selected(Enemy)
signal new_event_begun(realtime: int)
signal final_replay_reset

func select_enemy(e: Enemy):
	enemy_selected.emit(e)

func new_event(realtime: int):
	new_event_begun.emit(realtime)
