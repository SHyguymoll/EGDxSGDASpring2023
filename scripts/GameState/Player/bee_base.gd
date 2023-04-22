class_name Bee

extends CharacterBody2D

@export var health : float
@export var atk : float
@export var atk_timer : float
@export var speed : float
@export var leader : Bee_Leader
@export var target : Target
@export var formation_closeness : float
@export var team = "Player"

const COMPLETION_RANGE = 10
@onready var mode : String
@onready var target_position : Vector2
@onready var target_position_randomize : Vector2 = random_pos()
@onready var atk_time = atk_timer

@onready var modes = ["hover", "follow", "directed", "death"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func random_pos():
	return Vector2(randf() - 0.5, randf() - 0.5)*(100 - formation_closeness)

func attack():
	atk_time = 0
	$Animate.anim_state = "Attack"
	var candidates = $Hurtbox.get_overlapping_bodies()
	candidates[randi_range(0, len(candidates) - 1)].pain(atk, speed)
	
func pain(dmg: float, accuracy: float):
	if randf() > (speed - accuracy)/speed:
		health -= dmg
	if health <= 0:
		$Animate.anim_state = "Die"

func handle_death():
	if $Animate.is_playing() == false:
		queue_free()

func _process(_delta):
	$AttackBar.value = (atk_time/atk_timer) * 100
	$AttackBar.visible = true if $AttackBar.value < 100 else false

func tickTimers():
	atk_time = min(atk_time + 1, atk_timer)

func _physics_process(_delta):
	match mode:
		"hover", "follow", "directed":
			#yo dog I heard you liked match statements
			match mode:
				"hover":
					target_position = position
				"follow":
					target_position = leader.position + random_pos() + target_position_randomize
				"directed":
					target_position = target.position + target_position_randomize if target.used else target_position
			if $Hurtbox.has_overlapping_bodies():
				mode = "attack"
			position += (target_position - position).normalized() * speed
			if mode == "directed" and target.used:
				if position.distance_to(target_position) < COMPLETION_RANGE:
					target.movement_completed = true
					target = null
					mode = "hover"
		"attack":
			if atk_time == atk_timer:
				attack()
			if atk_time > atk_timer / 5 - 1:
				mode = "hover"
		"death":
			handle_death()
	tickTimers()
