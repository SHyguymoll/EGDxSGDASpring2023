extends AnimatedSprite2D
@export var start = 0.0
var part = 0
@onready var timer = 0.0

func _process(delta):
	match part:
		0:
			timer += delta
			if timer >= start:
				play()
				part = 1
		1:
			if !is_playing(): queue_free()
