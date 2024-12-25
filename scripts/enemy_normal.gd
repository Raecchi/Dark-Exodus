extends "res://scripts/character_script.gd"

@export var pattern_string = ""

var rng = RandomNumberGenerator.new()
var rng_number = 0

var unique_id = 0.0
var direction
var target = Vector2.ZERO
var orientation = 1
var type = 0
var color = 0
var attack = 2

var is_dead = false

func _ready():
	type = 1
	get_health()
	speed = 360 + ((GameData.get_level() * 60) / 3)
	call_deferred("_find_target")
	direction = (target - position).normalized()
	#print(unique_id)

func _physics_process(delta):
	$life/text.set_text(pattern_string)
	position += direction * speed * delta
	if hp <= 0:
		rpc("sync_health", unique_id)
		queue_free()


func _find_target():
	if orientation == 1:
		target = $direction/left.position
		if color == 0:
			$AnimatedSprite2D.play("default")
		elif color == 1:
			$AnimatedSprite2D.play("red")
	elif orientation == 2:
		target = $direction/right.position
		$AnimatedSprite2D.flip_h = true
		if color == 0:
			$AnimatedSprite2D.play("default")
		elif color == 1:
			$AnimatedSprite2D.play("blue")
	direction = (target - position).normalized()

func get_health():
	rng.randomize()
	if type == 1:
		if GameData.get_level() < 3:
			hp = 1
		elif GameData.get_level() >= 3 and GameData.get_level() < 7:
			hp = rng.randi_range(1,2)
		else:
			hp = rng.randi_range(1,3)
	for i in hp:
		rng_number = rng.randi_range(1,5)
		if rng_number <= 3:
			pattern_string = pattern_string + "."
		else:
			pattern_string = pattern_string + "-"
	#print (pattern_string)

@rpc
func sync_health(id):
	if unique_id == id:
		queue_free()
