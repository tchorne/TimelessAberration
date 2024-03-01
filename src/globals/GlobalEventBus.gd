extends Node

signal enemy_selected(Enemy)

func select_enemy(e: Enemy):
	enemy_selected.emit(e)
