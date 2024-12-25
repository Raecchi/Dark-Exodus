extends Node2D

var spawners = []

var enemy_spawned = 0
var level = GameData.get_level()
var failure = false
var success = false
var cinematic_timer = 0

func _ready():
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	MusicController.play_single()
	GameData.set_game_on(true)
	for i in range(1,9):
		spawners.append($spawners.get_node("spawner" + str(i)))

func _physics_process(delta):
	if GameData.get_spawn_time() == 60:
		GameData.set_spawn_time(0)
		if enemy_spawned < 27:
			activate_spawner()
			enemy_spawned += 1
			print("Enemy spawned: " + str(enemy_spawned))
		
	if level != GameData.get_level():
		level = GameData.get_level()
		enemy_spawned = 0
	
	if GameData.get_p1_hp() <= 0:
		GameData.set_game_on(false)
		failure = true
	
	if level == 16:
		GameData.set_game_on(false)
		success = true
	
	if failure:
		cinematic_timer += 1
		if cinematic_timer == 180:
			$foreground/fail.visible = true
		elif cinematic_timer == 300:
			$AnimationPlayer.play("fade_out")
			await $AnimationPlayer.animation_finished
			get_tree().change_scene_to_file("res://map/title_screen.tscn")
	elif success:
		cinematic_timer += 1
		if cinematic_timer == 180:
			$foreground/won.visible = true
		elif cinematic_timer == 300:
			$AnimationPlayer.play("fade_out")
			await $AnimationPlayer.animation_finished
			get_tree().change_scene_to_file("res://map/title_screen.tscn")


func _on_lose_area_body_entered(body):
	if body.is_in_group("enemy"):
		GameData.set_p1_hp(GameData.get_p1_hp() - body.attack)


func activate_spawner():
	var random_spawn = spawners[randi() % spawners.size()]
	random_spawn.spawn_enemy(false)
