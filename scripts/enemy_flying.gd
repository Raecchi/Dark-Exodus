extends "res://scripts/enemy_normal.gd"

func _ready():
	hp = 2
	type = 2
	get_health()
	speed = 360 + ((GameData.get_level() * 60) / 3)
	call_deferred("_find_target")
	direction = (target - position).normalized()
