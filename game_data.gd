extends Node

var level = 15
var parsec = 0
var sec = 0
var game_on = false
var game_mode = 0
var spawn_time = 0

var is_host = false
var is_online = false
var host_id = 1
var client_id = 0

var p1_hp = 0
var p1_power = 0
var p1_bar = 0
var p2_hp = 0
var p2_power = 0
var p2_bar = 0

var players = {}

func _physics_process(delta):
	
	if game_on == true:
		parsec += 1
		if parsec >= 60:
			parsec -= 60
			sec += 1
			if sec >= 30:
				level += 1
				sec = 0
		
		spawn_time += 1
	
	

func get_level():
	return level

func set_level(num):
	level = num

func get_parsec():
	return parsec

func get_sec():
	return sec

func get_game_mode():
	return game_mode

func set_game_mode(gamemo):
	game_mode = gamemo

func get_p1_hp():
	return p1_hp

func get_p1_power():
	return p1_power

func get_p1_bar():
	return p1_bar

func get_p2_hp():
	return p2_hp

func get_p2_power():
	return p2_power

func get_p2_bar():
	return p2_bar

func set_p1_hp(hp):
	p1_hp = hp

func set_p1_power(power):
	p1_power = power

func set_p1_bar(bar):
	p1_bar = bar

func set_p2_hp(hp):
	p2_hp = hp

func set_p2_power(power):
	p2_power = power

func set_p2_bar(bar):
	p2_bar = bar

func get_spawn_time():
	return spawn_time

func set_spawn_time(num):
	spawn_time = num

func get_game_on():
	return game_on

func set_game_on(value):
	game_on = value

func get_is_host():
	return is_host

func set_is_host(condi):
	is_host = condi

func get_is_online():
	return is_online

func set_is_online(condi):
	is_online = condi

func get_client_id():
	return client_id

func set_client_id(id):
	client_id = id
