extends CharacterBody2D

@export var health : float = 1.0
@export var atk : float = 0.35
@export var atk_speed = 35
@export var speed : float = 0.5
@export var mode = "hover"
@export var leader : Node2D = null
@export var formation_closeness : float = 10
@export var team = "Player"

var target_position : Vector2 = Vector2.ZERO
var last_atk = 0

var active = false
var modes = ["hover", "follow", "directed", "death"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func random_pos():
	return Vector2(randf() - 0.5, randf() - 0.5)*(10 - formation_closeness)

func attack():
	$Animate.anim_state = "Attack"
	var candidates = $Hurtbox.get_overlapping_bodies()
	candidates[randi_range(0, len(candidates) - 1)].pain(atk, speed)
	
func pain(dmg: float, accuracy: float):
	if randf() > (speed - accuracy)/speed:
		health -= dmg
	if health <= 0:
		$Animate.anim_state = "Die"

func _physics_process(delta):
	match mode:
		"hover", "follow", "directed":
			#yo dog I heard you liked match statements
			match mode:
				"hover", "death":
					target_position = position
				"follow":
					target_position = leader.position
			if $Hurtbox.has_overlapping_bodies():
				mode = "attack"
			position = lerp(
				position,
				target_position + random_pos(),
				speed)
		"attack":
			if last_atk == 0:
				attack()
				last_atk = atk_speed
	
	last_atk = max(last_atk - 1, 0)
