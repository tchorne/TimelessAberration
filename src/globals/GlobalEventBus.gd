extends Node

signal enemy_selected(Enemy)
signal new_event_begun

func select_enemy(e: Enemy):
	enemy_selected.emit(e)

func new_event():
	new_event_begun.emit()
