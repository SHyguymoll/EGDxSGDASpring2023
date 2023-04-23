class_name Bee

extends CharacterBody2D

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

const COMPLETION_RANGE = 10
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

var target : Target
var current_target

func try_sfx(node_name : String):
	if sfx.get_node_or_null(node_name) != null:
		sfx.get_node(node_name).emitting = true

# Called when the node enters the scene tree for the first time.
func _ready():
	try_sfx("Spawn")
	pass # Replace with function body.

func random_pos():
	return Vector2(randf() - 0.5, randf() - 0.5)*(100 - formation_closeness)

func reduce_candidates(candidates):
	var new_list = []
	for cand in candidates:
		if cand.get_parent() is Bee:
			if cand.get_parent().team != team:
				new_list.append(cand.get_parent())
	return new_list

func sight_decision():
	if !is_instance_valid(current_target):
		current_target = can_see[max(randi_range(0, len(can_see) - 1), 0)]
		target = worldspace.attach_target(current_target, "bee_solder_attack")
		mode = "directed"

func leader_on_attack():
	pass

func attack():
	leader_on_attack()
	atk_time = 0
	$Animate.anim_state = "Attack"
	var pick_enemy = can_hurt[max(randi_range(0, len(can_hurt) - 1), 0)]
	if is_instance_valid(pick_enemy):
		pick_enemy.pain(atk, accuracy)
	mode = "post_attack"

func clean_invalid_entries():
	var new_can_see := []
	for entry in can_see:
		if is_instance_valid(entry):
			new_can_see.append(entry)
	var new_can_hurt := []
	for entry in can_hurt:
		if is_instance_valid(entry):
			new_can_hurt.append(entry)
	can_see = new_can_see
	can_hurt = new_can_hurt

func post_attack():
	if (atk_time > ((atk_timer / 5) - 1)):
		if leader: mode = "follow"
		else: mode = "hover"
		if $Animate.is_playing() == false:
			$Animate.anim_state = "Idle"

func pain(dmg: float, dmg_accuracy: float):
	if randf() > (accuracy - dmg_accuracy)/accuracy:
		health -= dmg
	if health <= 0:
		mode = "death"

func handle_death():
	if leader != null:
		leader.leader_data.bee.erase(self)
		leader = null
	if $Animate.is_playing() == false:
		worldspace.explosion(global_position + random_pos(), 0.0)
		queue_free()

func _process(_delta):
	$AttackBar.value = (atk_time/atk_timer) * 100
	$AttackBar.visible = ($AttackBar.value < 100)
	$HealthBar.value = (health/health_max) * 100
	$HealthBar.visible = ($HealthBar.value < 100)

func tickTimers():
	atk_time = min(atk_time + 1, atk_timer)

func debug():
	pass
	#print(target.global_position)

func pick_location():
	match mode:
		"hover":
			target_position = global_position
		"follow":
			target_position = leader.global_position + random_pos() + target_position_randomize
		"directed":
			if is_instance_valid(target):
				target_position = target.global_position + target_position_randomize if target.used else global_position
			else:
				if is_instance_valid(leader):
					mode = "follow"
				else:
					mode = "hover"

func post_movement():
	if is_instance_valid(target):
		if mode == "directed" and target.used:
			if position.distance_to(target_position) < COMPLETION_RANGE:
				target.movement_completed = true
				mode = "hover"

func _physics_process(_delta):
	match mode:
		"hover", "follow", "directed":
			$Animate.anim_state = "Idle"
			$Animate.play()
			can_see = reduce_candidates(detect.get_overlapping_areas())
			if len(can_see) > 0:
				sight_decision()
			can_hurt = reduce_candidates(throw_hands.get_overlapping_areas())
			if len(can_hurt) > 0:
				mode = "attack"
			#yo dog I heard you liked match statements
			pick_location()
			global_position += global_position.direction_to(target_position) * speed
			post_movement()
		"attack":
			if atk_time == atk_timer:
				attack()
		"post_attack":
			post_attack()
		"death":
			$Animate.anim_state = "Death"
			handle_death()
	tickTimers()
	clean_invalid_entries()
