extends AnimatedSprite2D

@export var anim_state = "Idle"
var timer = 0
var dir = 1
const MAX_FLY_POS = 5
const MAX_CIRC = 10

func _ready():
	play()

func _physics_process(delta):
	animation = anim_state
	match anim_state:
		"Idle":
			timer += dir
			if abs(timer) > MAX_FLY_POS:
				dir = -(dir)
			position.y = timer
		"Attack":
			timer += dir
			if abs(timer) > MAX_CIRC:
				timer = 0
			position.y = sin(timer)
			position.x = cos(timer)
		"Death":
			timer += dir
			if abs(timer) > MAX_FLY_POS:
				dir = -(dir)
			position.y = timer
	
