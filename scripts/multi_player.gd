extends Node2D

var spawner_left = []
var spawner_right = []

var level = GameData.get_level()

var enemy_spawned = 0
var p1_win = false
var p2_win = false
var cinematic_timer = 0
var is_host = false


func _ready():
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	MusicController.play_multi()
	GameData.set_game_on(true)
	for i in range(1,8):
		spawner_left.append($spawners.get_node("left_spawner" + str(i)))
	for i in range(1,8):
		spawner_right.append($spawners.get_node("right_spawner" + str(i)))
	
	is_host = GameData.get_is_host()

#@rpc
#func sync_enemy_spawn(spawn_position,spawn_orientation,enemy_type,from_player):
	#for spawner in spawner_left + spawner_right:
		#spawner.sync_spawn_enemy(spawn_position,spawn_orientation,enemy_type,from_player)

func _physics_process(delta):
	if is_host:
		if GameData.get_spawn_time() == 60:
			GameData.set_spawn_time(0)
			if enemy_spawned < 27:
				activate_spawner()
				enemy_spawned += 1
	
	if GameData.get_p1_bar() >= 100:
		GameData.set_p1_bar(0)
		if is_host:
			activate_player_right_spawner()
	elif GameData.get_p2_bar() >= 100:
		GameData.set_p2_bar(0)
		if is_host:
			activate_player_left_spawner()
		
	
	if level != GameData.get_level():
		level = GameData.get_level()
		enemy_spawned = 0
	
	check_game_end()

func activate_spawner():
	var random_spawn = spawner_left[randi() % spawner_left.size()]
	random_spawn.spawn_enemy(false)
	#rpc("sync_spawn", random_spawn.global_position, random_spawn.orientation, random_spawn.select_enemy_type(),false)
	random_spawn = spawner_right[randi() % spawner_right.size()]
	random_spawn.spawn_enemy(false)
	#rpc("sync_spawn", random_spawn.global_position, random_spawn.orientation, random_spawn.select_enemy_type(),false)


func activate_player_left_spawner():
	var random_spawn = spawner_left[randi() % spawner_left.size()]
	random_spawn.spawn_enemy(true)
	#rpc("sync_spawn", random_spawn.global_position, random_spawn.orientation, random_spawn.select_enemy_type(),true)


func activate_player_right_spawner():
	var random_spawn = spawner_right[randi() % spawner_right.size()]
	random_spawn.spawn_enemy(true)
	#rpc("sync_spawn", random_spawn.global_position, random_spawn.orientation, random_spawn.select_enemy_type(),true)


func check_game_end():
	if GameData.get_p1_hp() <= 0:
		GameData.set_game_on(false)
		p2_win = true
	
	if GameData.get_p2_hp() <= 0:
		GameData.set_game_on(false)
		p1_win = true
	
	if p1_win or p2_win:
		cinematic_timer += 1
		if cinematic_timer == 180:
			if p1_win:
				$foreground/p1_won.visible = true
			elif p2_win:
				$foreground/p1_won2.visible = true
		elif cinematic_timer == 300:
			$AnimationPlayer.play("fade_out")
			await $AnimationPlayer.animation_finished
			get_tree().change_scene_to_file("res://map/title_screen.tscn")


#@rpc
#func sync_spawn(global_pos, orientation, enemy_type, from_player):
	#for spawner in spawner_left + spawner_right:
		#if spawner.global_position == global_pos:
			#spawner.sync_spawn_enemy(global_pos,orientation,enemy_type,from_player)

func _on_left_body_entered(body):
	if body.is_in_group("enemy"):
		GameData.set_p1_hp(GameData.get_p1_hp() - body.attack)


func _on_right_body_entered(body):
	if body.is_in_group("enemy"):
		GameData.set_p2_hp(GameData.get_p2_hp() - body.attack)
