extends AnimatedSprite2D

@export var anim_state = "Idle"
var timer = 0
var dir = 1
const MAX_FLY_POS = 5
const MAX_CIRC = 10

func _ready():
	play()

func _physics_process(_delta):
	match get_parent().mode:
		"hover", "directed", "follow":
			anim_state = "Idle"
		"attack", "post_attack":
			anim_state = "Attack"
		"death":
			anim_state = "Death"
	animation = anim_state
	match anim_state:
		"Idle":
			timer += dir
			if abs(timer) > MAX_FLY_POS:
				dir = -(dir)
			position.y = timer
			position.x = 0
		"Attack":
			timer += dir
			if abs(timer) > MAX_CIRC:
				timer = 0
			position.y = sin(timer) * 2
			position.x = cos(timer) * 2
