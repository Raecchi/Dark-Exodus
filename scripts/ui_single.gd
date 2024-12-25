extends CanvasLayer

func _physics_process(delta):
	$top/ProgressBar.value = GameData.get_p1_hp()
	$top/level.text = "Lvl " + str(GameData.get_level())
	$bot/TextureProgressBar.value = GameData.get_p1_power()
