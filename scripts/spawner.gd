extends Marker2D

const BUG_COMMON_PATH = preload("res://object/enemy_normal.tscn")
const BUG_FLYING_PATH = preload("res://object/enemy_flying.tscn")
const BUG_FAST_PATH = preload("res://object/enemy_fast.tscn")

@export var orientation = 1

var rng = RandomNumberGenerator.new()
var rng_number = 0

var spawn = false
var type = 0
var from_player = false

func _physics_process(delta):
	if spawn:
		rng.randomize()
		if GameData.get_level() < 2:
			type = 1
		elif GameData.get_level() < 5 and GameData.get_level() >= 2:
			rng_number = rng.randi_range(1,3) #normal 66%, flying 33%
			if rng_number == 3:
				type = 2
			else:
				type = 1
		else:
			rng_number = rng.randi_range(1,5) #normal 40%, flying 30%, fast 30%
			match rng_number:
				4:
					type = 2
				5:
					type = 3
				_:
					type = 1
		match type:
			1:
				var enemy = BUG_COMMON_PATH.instantiate()
				enemy.position = global_position
				enemy.orientation = orientation
				if from_player :
					enemy.color = 1
				get_parent().add_child(enemy)
			2:
				var enemy = BUG_FLYING_PATH.instantiate()
				enemy.position = global_position
				enemy.orientation = orientation
				get_parent().add_child(enemy)
			3:
				var enemy = BUG_FAST_PATH.instantiate()
				enemy.position = global_position
				enemy.orientation = orientation
				get_parent().add_child(enemy)
		spawn = false
		from_player = false

@rpc
func sync_spawn_enemy(spawn_position, spawn_orientation, enemy_type, from_player):
	var enemy
	match enemy_type:
		1:
			enemy = BUG_COMMON_PATH.instantiate()
		2:
			enemy = BUG_FLYING_PATH.instantiate()
		3:
			enemy = BUG_FAST_PATH.instantiate()
	
	enemy.position = spawn_position
	enemy.orientation = spawn_orientation
	if from_player:
		enemy.color = 1
	get_parent().add_child(enemy)
