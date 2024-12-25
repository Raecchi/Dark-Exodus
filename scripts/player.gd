extends "res://scripts/character_script.gd"

const GUST_PATH = preload("res://object/gust.tscn")

@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

@export var player_id = 0
var swing_state = 0
var enemy_location = Vector2.ZERO
var direction = Vector2.ZERO
var attack_timer = 0
var go_back = false
var power_bar = 0.0

var enemy
var enemies = []
var timer = 0


func _ready():
	speed = 10000
	if player_id == 1:
		$MultiplayerSynchronizer.set_multiplayer_authority(1)
	elif player_id == 2:
		#$MultiplayerSynchronizer.set_multiplayer_authority(GameData.get_client_id())
		if multiplayer.get_unique_id() != 1:
			$MultiplayerSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())
		else:
			$MultiplayerSynchronizer.set_multiplayer_authority(GameData.get_client_id())
	
	
func _physics_process(delta):
	#print(multiplayer.get_unique_id())
	if multiplayer.get_unique_id() != $MultiplayerSynchronizer.get_multiplayer_authority():
		if GameData.get_is_online():
			return
	
	match player_id:
		2:
			if Input.is_action_pressed("P2 button"):
				attack_timer += 1
				attack_timer = min(attack_timer, 60)
				power_bar = (attack_timer / 60.0) * 100.0
				GameData.set_p2_power(power_bar)
				rpc("sync_power_bar", power_bar)
				#GameData.set_p2_power(power_bar)
			
			elif Input.is_action_just_released("P2 button"):
				move()
				attack()
				attack_timer = 0
		_:
			if Input.is_action_pressed("P1 button"):
				attack_timer += 1
				attack_timer = min(attack_timer, 60)
				power_bar = (attack_timer / 60.0) * 100.0
				GameData.set_p1_power(power_bar)
				rpc("sync_power_bar", power_bar)
				#GameData.set_p1_power(power_bar)
			
			elif Input.is_action_just_released("P1 button"):
				move()
				attack()
				attack_timer = 0
	
	if position.distance_to(enemy_location) > speed * delta:
		position += direction.normalized() * speed * delta
	else:
		position = enemy_location
	
	dynamic_enemy_sorting()
	
	
	if go_back:
		timer += 1
		if timer == 120:
			going_back()
	
	


func attack():
	if swing_state == 0:
		anim_state.travel("h_swing")
	else:
		anim_state.travel("v_swing")
	
	swing_state = (swing_state + 1) % 2
	
	SfxController.play_slash()
	
	if enemy != null:
		enemy.pattern_string = enemy.pattern_string.substr(1,enemy.pattern_string.length()-1)
		enemy.hp -= 1
		SfxController.play_hurt()
		if enemy.hp <= 0:
			enemies.erase(enemy)
			rpc("enemy_killed",enemy)
			if GameData.get_game_mode() == 2:
				match player_id:
					1:
						GameData.set_p1_bar(GameData.get_p1_bar() + 10)
					2:
						GameData.set_p2_bar(GameData.get_p2_bar() + 10)
	rpc("sync_attack")


func _on_enemy_detector_body_entered(body):
	if body.is_in_group("enemy"):
		enemies.append(body)


func dynamic_enemy_sorting():
	enemies.sort_custom(comparing_position)


func comparing_position(a,b):
	if player_id == 1:
		if a.global_position.x < b.global_position.x:
			return true
		return false
	else:
		if a.global_position.x > b.global_position.x:
			return true
		return false


func search_enemy():
	for i in enemies:
		if attack_timer < 10:
			if i.pattern_string.begins_with("."):
				enemy = i
				return i.global_position
		else:
			if i.pattern_string.begins_with("-"):
				enemy = i
				return i.global_position
	return position
	

func move():
	enemy_location = search_enemy()
	if enemy_location != position:
		go_back = true
		timer = 0
		if player_id == 1 or player_id == 0:
			enemy_location.x -= 50
		else:
			enemy_location.x += 50
		direction = (enemy_location - position).normalized()
		rpc("sync_position", enemy_location)
	var gust = GUST_PATH.instantiate()
	gust.position = $gust_spawner.global_position
	gust.id = player_id
	if player_id == 2:
		gust.scale.x = -2
	get_parent().add_child(gust)
	#speed = position.distance_to(enemy_location)


func going_back():
	enemy_location = $global/neutral_position.global_position
	direction = (enemy_location - position).normalized()
	go_back = false


func _on_enemy_detector_body_exited(body):
	if body.is_in_group("enemy"):
		enemies.erase(body)

@rpc
func sync_power_bar(power : float):
	power_bar = power
	GameData.set_p1_power(power_bar) if player_id == 1 else GameData.set_p2_power(power_bar)

@rpc
func sync_position(pos):
	position = pos

@rpc
func sync_attack():
	attack()

@rpc
func enemy_killed(enemy):
	for i in enemies:
		if i == enemy:
			enemies.erase(enemy)
			i.queue_free()
			break
