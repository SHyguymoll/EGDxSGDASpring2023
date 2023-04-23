extends AnimatedSprite2D
@export var start = 0.0
@export var sound_effect : AudioStreamPlayer2D
var part = 0
@onready var timer = 0.0

func _process(delta):
	match part:
		0:
			timer += delta
			if timer >= start:
				play()
				if sound_effect != null:
					sound_effect.play()
				part = 1
		1:
			if !is_playing(): queue_free()
