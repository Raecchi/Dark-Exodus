extends Node2D

var spawner_left = []
var spawner_right = []

var level = GameData.get_level()
var enemy_spawned = 0
var p1_win = false
var p2_win = false
var cinematic_timer = 0

@onready var is_online
@onready var is_host

func _ready():
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	MusicController.play_multi()
	GameData.set_game_on(true)

	for i in range(1, 8):
		spawner_left.append($spawners.get_node("left_spawner" + str(i)))
	for i in range(1, 8):
		spawner_right.append($spawners.get_node("right_spawner" + str(i)))
	
	is_host = GameData.get_is_host()
	is_online = GameData.get_is_online()

func _physics_process(delta):
	if is_online and is_host:
		online_logic()
	elif !is_online:
		local_logic()

func local_logic():
	if GameData.get_spawn_time() == 60:
		GameData.set_spawn_time(0)
		if enemy_spawned < 27:
			activate_spawner()
			enemy_spawned += 1

	if GameData.get_p1_bar() >= 100:
		GameData.set_p1_bar(0)
		activate_player_right_spawner()
	elif GameData.get_p2_bar() >= 100:
		GameData.set_p2_bar(0)
		activate_player_left_spawner()

	if level != GameData.get_level():
		level = GameData.get_level()
		enemy_spawned = 0

	handle_game_end()

func online_logic():
	if GameData.get_spawn_time() == 60:
		GameData.set_spawn_time(0)
		if enemy_spawned < 27:
			rpc("sync_activate_spawner")
			enemy_spawned += 1

	# Handle player-triggered spawns
	if GameData.get_p1_bar() >= 100:
		GameData.set_p1_bar(0)
		rpc("sync_activate_player_right_spawner")
	elif GameData.get_p2_bar() >= 100:
		GameData.set_p2_bar(0)
		rpc("sync_activate_player_left_spawner")

	# Update level and reset spawn count
	if level != GameData.get_level():
		level = GameData.get_level()
		enemy_spawned = 0

	# Handle win/loss conditions (host-only)
	handle_game_end()

func handle_game_end():
	if GameData.get_p1_hp() <= 0:
		GameData.set_game_on(false)
		p2_win = true
	elif GameData.get_p2_hp() <= 0:
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

# Local and Online Spawner Activation
func activate_spawner():
	var left_spawner = spawner_left[randi() % spawner_left.size()]
	var right_spawner = spawner_right[randi() % spawner_right.size()]
	left_spawner.spawn_enemy(false)
	right_spawner.spawn_enemy(false)

func activate_player_left_spawner():
	var spawner = spawner_left[randi() % spawner_left.size()]
	spawner.spawn_enemy(true)

func activate_player_right_spawner():
	var spawner = spawner_right[randi() % spawner_right.size()]
	spawner.spawn_enemy(true)

# Online Synchronization (Host Only)
@rpc
func sync_activate_spawner():
	activate_spawner()

@rpc
func sync_activate_player_left_spawner():
	activate_player_left_spawner()

@rpc
func sync_activate_player_right_spawner():
	activate_player_right_spawner()


func _on_left_body_entered(body):
	if body.is_in_group("enemy"):
		GameData.set_p1_hp(GameData.get_p1_hp() - body.attack)




func _on_right_body_entered(body):
	if body.is_in_group("enemy"):
		GameData.set_p2_hp(GameData.get_p2_hp() - body.attack)
