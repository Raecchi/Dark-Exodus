extends AudioStreamPlayer

var HURT = preload("res://sound/hurt.wav")
var SLASH = preload("res://sound/sword-swipes-7174.wav")
var beep = preload("res://sound/beep.wav")
var choice = preload("res://sound/select.wav")

func play_hurt():
	stream = HURT
	volume_db = -10
	play()

func play_slash():
	stream = SLASH
	volume_db = -10
	play()

func play_beep():
	stream = beep
	volume_db = 0
	play()

func play_choice():
	stream = choice
	volume_db = 0
	play()
