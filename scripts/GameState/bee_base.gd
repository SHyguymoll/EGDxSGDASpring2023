class_name Bee extends CharacterBody2D

@export var health : float
@export var health_max : float
@export var atk : float
@export var atk_timer : float
@export var speed : float
@export var accuracy : float
@export var leader : Bee_Leader
@export var score_gain : int
@export var formation_closeness : float
@export var team : String

@onready var mode : String
@onready var target_position : Vector2
@onready var target_position_randomize : Vector2 = random_pos()
@onready var atk_time = atk_timer
@onready var sfx = $Effects
@onready var throw_hands = $HurtBox
@onready var detect = $DetectBox
@onready var modes = ["hover", "follow", "directed", "attack", "post_attack", "death"]
@onready var worldspace : world = get_tree().get_root().get_node("Stage")

var can_see = []
var can_hurt = []

var current_enemy #refers to a Bee or Building
var current_target #refers to a Target

func try_sfx(node_name : String):
	if sfx.get_node_or_null(node_name) != null:
		sfx.get_node(node_name).emitting = true

# Called when the node enters the scene tree for the first time.
func _ready():
	try_sfx("Spawn")
	pass # Replace with function body.

func random_pos():
	return Vector2(randf() - 0.5, randf() - 0.5)*(100 - formation_closeness)

func _process(_delta):
	$AttackBar.value = (atk_time/atk_timer) * 100
	$AttackBar.visible = ($AttackBar.value < 100)
	$HealthBar.value = (health/health_max) * 100
	$HealthBar.visible = ($HealthBar.value < 100)

func pick_location():
	match mode:
		"hover", "attack", "post_attack", "death":
			target_position = global_position
		"follow":
			target_position = leader.global_position + random_pos() + target_position_randomize
		"directed":
			if current_target != null:
				if current_target.used:
					target_position = current_target.global_position
			else:
				target_position = global_position

func move_bee_towards_target():
	global_position += global_position.direction_to(target_position) * speed

func reduce_candidates(candidates):
	var new_list = []
	for cand in candidates:
		if cand.get_parent() is Bee or cand.get_parent() is Building:
			if cand.get_parent().team != team:
				new_list.append(cand.get_parent())
	return new_list

func detect_enemies():
	can_see = reduce_candidates(detect.get_overlapping_areas())
	can_hurt = reduce_candidates(throw_hands.get_overlapping_areas())

func change_enemy():
	if len(can_see) > 0:
		current_enemy = can_see.pick_random()

func order(new_order : String, new_target : Target):
	match new_order:
		"hold":
			mode = "hover"
		"push":
			current_target = new_target
			mode = "directed"

func reset_mode():
	if current_target != null:
		mode = "directed"
	else:
		if leader != null:
			mode = "follow"
		else:
			mode = "hover"

func attack_enemy():
	atk_time = 0
	$Animate.anim_state = "Attack"
	can_hurt.pick_random().pain(atk, accuracy)

func tick_timers():
	atk_time = min(atk_time + 1, atk_timer)
	check_attack()

func check_attack():
	if (atk_time > ((atk_timer / 5) - 1)):
		reset_mode()
		if $Animate.is_playing() == false:
			$Animate.anim_state = "Idle"

func pain(dmg: float, dmg_accuracy: float):
	if randf() > (accuracy - dmg_accuracy)/accuracy:
		health -= dmg

func handle_death():
	if leader != null:
		leader.squad.erase(self)
		leader = null
	queue_free()
