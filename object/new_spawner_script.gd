extends Marker2D

const BUG_COMMON_PATH = preload("res://object/enemy_normal.tscn")
const BUG_FLYING_PATH = preload("res://object/enemy_flying.tscn")
const BUG_FAST_PATH = preload("res://object/enemy_fast.tscn")

@export var orientation = 1

var rng = RandomNumberGenerator.new()
var unique_id = 0

func spawn_enemy(from_player):
	var enemy
	rng.randomize()
	unique_id = int(rng.randi())
	var type = select_enemy_type()
	match type:
		1:
			enemy = BUG_COMMON_PATH.instantiate()
		2:
			enemy = BUG_FLYING_PATH.instantiate()
		3:
			enemy = BUG_FAST_PATH.instantiate()
	enemy.position = global_position
	enemy.orientation = orientation
	enemy.unique_id = unique_id
	if from_player:
		enemy.color = 1
	get_parent().add_child(enemy)
	rpc("sync_spawn_enemy",global_position, orientation, type, from_player, unique_id)

func select_enemy_type():
	if GameData.get_level() < 2:
		return 1  # Normal enemy
	elif GameData.get_level() < 5:
		return rng.randi_range(1, 2)  # Normal or Flying enemy
	else:
		return rng.randi_range(1, 3)  # Normal, Flying, or Fast enemy
	

@rpc
func sync_spawn_enemy(global_pos, orientation, type, from_player, id):
	var enemy
	match type:
		1:
			enemy = BUG_COMMON_PATH.instantiate()
		2:
			enemy = BUG_FLYING_PATH.instantiate()
		3:
			enemy = BUG_FAST_PATH.instantiate()
	enemy.position = global_pos
	enemy.orientation = orientation
	enemy.unique_id = id
	if from_player:
		enemy.color = 1
	get_parent().add_child(enemy)
