class_name Bee

extends CharacterBody2D

@export var health : float
@export var health_max : float
@export var atk : float
@export var atk_timer : float
@export var speed : float
@export var accuracy : float
@export var leader : Bee_Leader

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
@onready var worldspace = get_tree().get_root().get_node("Stage")

var can_see = []
var can_hurt = []


var target : Target

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

func leader_action(): #for Commanders
	pass

func leader_on_attack(): #ditto
	pass

func attack():
	leader_on_attack()
	atk_time = 0
	$Animate.anim_state = "Attack"
	can_hurt[max(randi_range(0, len(can_hurt) - 1), 0)].pain(atk, accuracy)
	mode = "post_attack"

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
	$AttackBar.visible = true if $AttackBar.value < 100 else false
	$HealthBar.value = (health/health_max) * 100
	$HealthBar.visible = true if $HealthBar.value < 100 else false

func tickTimers():
	atk_time = min(atk_time + 1, atk_timer)

func _physics_process(_delta):
	match mode:
		"hover", "follow", "directed":
			$Animate.anim_state = "Idle"
			$Animate.play()
			can_see = reduce_candidates(detect.get_overlapping_areas())
			if len(can_see) > 0:
				leader_action()
			can_hurt = reduce_candidates(throw_hands.get_overlapping_areas())
			if len(can_hurt) > 0:
				mode = "attack"
			#yo dog I heard you liked match statements
			match mode:
				"hover":
					target_position = global_position
				"follow":
					target_position = leader.global_position + random_pos() + target_position_randomize
				"directed":
					target_position = target.global_position + target_position_randomize if target.used else target_position
			global_position += global_position.direction_to(target_position) * speed
			if mode == "directed" and target.used:
				if position.distance_to(target_position) < COMPLETION_RANGE:
					target.movement_completed = true
					mode = "hover"
		"attack":
			if atk_time == atk_timer:
				attack()
		"post_attack":
			post_attack()
		"death":
			$Animate.anim_state = "Death"
			handle_death()
	tickTimers()
