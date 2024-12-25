extends AudioStreamPlayer

const SINGLE = preload("res://sound/music/2021-08-30_-_Boss_Time_-_www.FesliyanStudios.com.wav")
const MULTI = preload("res://sound/music/2021-10-19_-_Funny_Bit_-_www.FesliyanStudios.com.wav")

func play_single():
	stream = SINGLE
	play()

func play_multi():
	stream = MULTI
	play()
