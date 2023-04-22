extends AnimatedSprite2D

func _process(_delta): if !is_playing(): queue_free()
