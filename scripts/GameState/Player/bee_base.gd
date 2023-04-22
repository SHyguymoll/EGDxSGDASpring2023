extends CharacterBody2D

@export var health : float
@export var atk : float
@export var atk_speed : float
@export var speed : float
@export var leader : CharacterBody2D
@export var target : Node2D
@export var formation_closeness : float
@export var team = "Player"

var mode = "hover"
var target_position : Vector2 = Vector2.ZERO
var last_atk = 0
var death_timer = 10

var active = false
var modes = ["hover", "follow", "directed", "death"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func random_pos():
	return Vector2(randf() - 0.5, randf() - 0.5)*(1000 - formation_closeness)

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
				"hover":
					target_position = position
				"follow":
					target_position = leader.position
				"directed":
					target_position = target.position
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
		"death":
			if death_timer == 0:
				queue_free()
			death_timer -= 1
	
	last_atk = max(last_atk - 1, 0)
