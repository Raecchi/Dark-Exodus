extends "res://scripts/enemy_normal.gd"

func _ready():
	hp = 1
	type = 3
	attack = 3
	get_health()
	speed = 660
	call_deferred("_find_target")
	direction = (target - position).normalized()
