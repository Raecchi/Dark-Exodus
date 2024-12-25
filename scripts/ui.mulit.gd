extends CanvasLayer

func _physics_process(delta):
	$top/p1_bar.value = GameData.get_p1_hp()
	$top/lvl.text = "Lvl " + str(GameData.get_level())
	$top/p1_sp_bar.value = GameData.get_p1_bar()
	$top/p2_bar.value = GameData.get_p2_hp()
	$top/p2_sp_bar.value = GameData.get_p2_bar()
	
	$bot/p2_bar.value = GameData.get_p2_power()
	$bot/p1_bar.value = GameData.get_p1_power()
	
