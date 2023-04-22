extends AnimatedSprite2D

func _process(delta): if !is_playing(): queue_free()
