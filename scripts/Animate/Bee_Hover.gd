extends AnimatedSprite2D

var state = "Idle"
var timer = 0
var dir = 1
const MAX_FLY_POS = 5

func _physics_process(delta):
	animation = state
	match state:
		"Idle":
			timer += dir
			if abs(timer) > MAX_FLY_POS:
				dir = -(dir)
				position.y = timer
		"Attack":
			timer += dir
			if abs(timer) > MAX_FLY_POS:
				dir = -(dir)
				position.y = timer
		"Death":
			timer += dir
			if abs(timer) > MAX_FLY_POS:
				dir = -(dir)
				position.y = timer
	
