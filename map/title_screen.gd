extends Node2D

var blink_time = 0
#var game_ready = false
var option = 1
var screen_on = false
var multi_option_1 = false
var multi_option_2 = false
var lobby = false

var button_timer = 0
var port = 9999
var host = false
var has_player = false

var peer = ENetMultiplayerPeer.new()


func _ready():
	MusicController.stop()

func _physics_process(delta):
	
	match option:
		1:
			$AnimatedSprite2D.set_position(Vector2(232,464))
		2:
			$AnimatedSprite2D.set_position(Vector2(728,456))
		3:
			$AnimatedSprite2D.set_position(Vector2(496,560))
	
	if Input.is_action_pressed("P1 button") or Input.is_action_pressed("P2 button"):
		button_timer += 1
		button_timer = min(button_timer, 60)
	
	elif Input.is_action_just_released("P1 button") or Input.is_action_just_released("P2 button"):
		gauge()
		button_timer = 0
	
	$UI/TextureProgressBar.value = button_timer


func gauge():
	if button_timer <= 10:
		if !screen_on:
			option += 1
			if option > 3:
				option = 1
			SfxController.play_beep()
	else:
		match option:
			1:
				if !multi_option_1 and !multi_option_2 and !lobby:
					SfxController.play_choice()
					await SfxController.finished
					$AnimationPlayer.play("fade_out")
					await $AnimationPlayer.animation_finished
					GameData.set_game_mode(1)
					GameData.set_p1_hp(100)
					GameData.set_level(0)
					get_tree().change_scene_to_file("res://map/single_player.tscn")
				elif multi_option_1:
					SfxController.play_choice()
					await SfxController.finished
					$AnimationPlayer.play("fade_out")
					await $AnimationPlayer.animation_finished
					GameData.set_game_mode(2)
					GameData.set_p1_hp(100)
					GameData.set_p1_bar(0)
					GameData.set_level(0)
					GameData.set_p2_hp(100)
					GameData.set_p2_bar(0)
					GameData.set_is_host(true)
					get_tree().change_scene_to_file("res://map/multi_player.tscn")
				elif multi_option_2:
					SfxController.play_choice()
					await SfxController.finished
					multi_option_2 = false
					lobby = true
					option= 1
					host = true
					$online.visible = false
					$Lobby.visible = true
					peer.create_server(port)
					multiplayer.multiplayer_peer = peer
					multiplayer.peer_connected.connect(player_detector)
					multiplayer.connected_to_server.connect(connect_to_serve)
					multiplayer.peer_disconnected.connect
					#SendPlayerInfo($online/name.text, multiplayer.get_unique_id())
					upnp_setup()
					
			2:
				if !multi_option_1 and !multi_option_2 and !lobby:
					SfxController.play_choice()
					await SfxController.finished
					multi_option_1 = true
					option = 1
					$mid.visible = false
					$Multiplayer.visible = true
				elif multi_option_1:
					SfxController.play_choice()
					await SfxController.finished
					multi_option_1 = false
					multi_option_2 = true
					option = 1
					$Multiplayer.visible = false
					$online.visible = true
				elif multi_option_2:
					SfxController.play_choice()
					await SfxController.finished
					multi_option_2 = false
					lobby = true
					option = 1
					$online.visible = false
					$Lobby.visible = true
					peer.create_client($online/address.text, port)
					multiplayer.multiplayer_peer = peer
					$Lobby/player_detector.text = "Joined lobby"
					$Lobby/Start.text = "Waiting for host"
				elif lobby:
					if host and has_player:
						SfxController.play_choice()
						await SfxController.finished
						change_multi_online()
						GameData.set_is_host(true)
						setting_unique_ids()
						rpc("client_change_scene")
			3:
				if !multi_option_1 and !multi_option_2 and !lobby:
					if !screen_on:
						SfxController.play_choice()
						await SfxController.finished
						$How_to_play.visible = true
						screen_on = true
					else:
						$How_to_play.visible = false
						screen_on = false
				elif multi_option_1:
					SfxController.play_choice()
					await SfxController.finished
					multi_option_1 = false
					option = 1
					$Multiplayer.visible = false
					$mid.visible = true
				elif multi_option_2:
					SfxController.play_choice()
					await SfxController.finished
					multi_option_2 = false
					multi_option_1 = true
					option = 1
					$Multiplayer.visible = true
					$online.visible = false
				elif lobby:
					SfxController.play_choice()
					await SfxController.finished
					multi_option_2 = true
					lobby = false
					host = false
					option = 1
					$online.visible = true
					$Lobby.visible = false
					peer.close()
		

func player_detector(id):
	$Lobby/player_detector.text = "Player Joined"
	has_player = true
	if id == 1:
		rpc_id(id, "set_player_id",1)
	elif id == 2:
		rpc_id(id, "set_plaeyr_id",1)

func player_leave(id):
	$Lobby/player_detector.text = "No Player Joined"
	has_player = false

func connect_to_serve():
	print("A player has joined")
	#SendPlayerInfo.rpc_id(1, $online/name.text, multiplayer.get_unique_id())

func change_multi_online():
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	GameData.set_game_mode(2)
	GameData.set_p1_hp(100)
	GameData.set_p1_bar(0)
	GameData.set_level(0)
	GameData.set_p2_hp(100)
	GameData.set_p2_bar(0)
	GameData.set_is_online(true)
	get_tree().change_scene_to_file("res://map/multi_player.tscn")

@rpc
func client_change_scene():
	change_multi_online()

func setting_unique_ids():
	var peers = multiplayer.get_peers()
	for peer in peers:
		#print(peer)
		if peer != multiplayer.get_unique_id():
			GameData.set_client_id(peer)
			break

#@rpc("any_peer","call_local")
#func SendPlayerInfo(name,id):
	#if !GameData.players.has(id):
		#GameData.players[id] = {"name": name, "id": id}
	#
	#if multiplayer.is_server():
		#for i in GameData.players:
			#SendPlayerInfo.rpc(GameData.players[i].name, i)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	#assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		#"UPNP Discover Failed! Error %s" % discover_result)
	#
	#assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateaway(), \
		#"UPNP Invalid Gateaway!")
	
	var map_result = upnp.add_port_mapping(port)
	#assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		#"UPNP Port Mapping Failed! Error %s" % map_result)
	
