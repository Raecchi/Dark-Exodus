extends AnimatedSprite2D

var id = 0
var timer = 0

func _ready():
	match id:
		0:
			play("white")
		1:
			play("blue")
		2:
			play("red")
		

func _physics_process(delta: float) -> void:
	timer += 1
	if timer == 30:
		queue_free()
