class_name Bee_Leader extends "res://scripts/GameState/Player/bee_base.gd"

@export var start : Building
@export var spawn : String
@export var spawn_time : int
@export var spawn_timer : int
@export var ability_time : int
@export var ability_timer : int
@export var resp_time : int
@export var resp_timer : int
@export var encounter_move : String
@export var soldier_limit : int

var target_icon = preload("res://scenes/TargetPosition.tscn")

var squad : Array[Bee] = []
var other_data : Array = []

var hovered = false
var selected = false

func debug():
	pass

func tick_timers():
	atk_time = min(atk_time + 1, atk_timer)
	spawn_time = min(spawn_time + 1, spawn_timer)
	ability_time = min(ability_time + 1, ability_timer)

func handle_death(): #Legends never die, they just respawn
	if $Animate.is_playing() == false:
		visible = false
		global_position = start.global_position
		resp_time = 0
	if resp_time == resp_timer:
		mode = "hover"
		visible = true
	resp_time = min(resp_time + 1, resp_timer)

func change_target(): #for Commanders
	if len(can_see) > 0:
		match encounter_move:
			"rushdown": #just pick a new one without any thought
				current_target = can_see.pick_random()
				worldspace.attach_target(current_target, "bee_lead_attack")
				for bee in squad:
					bee.order("push", current_target.global_position)
	else: #no enemies in sight
		current_target = null

func leader_on_attack(): #ditto
	pass

func use_ability(): #ditthree
	pass

func _on_mouse_entered():
	hovered = true

func _on_mouse_exited():
	hovered = false

func _process(_delta):
	soldier_limit = (start.level + 1) * 3
	@warning_ignore("integer_division")
	$AttackBar.value = (atk_time/atk_timer) * 100
	$AttackBar.visible = ($AttackBar.value < 100)
	$HealthBar.value = (health/health_max) * 100
	$HealthBar.visible = ($HealthBar.value < 100)
	$SelectLight.visible = hovered or selected
	@warning_ignore("integer_division")
	$BeeCreateBar.value = (float(spawn_time)/spawn_timer) * 100
	$BeeCreateBar.visible = ($BeeCreateBar.value < 100)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and hovered:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected = !selected
			if selected:
				if worldspace.selected_leader != self and worldspace.selected_leader != null:
					worldspace.selected_leader.selected = false
				if worldspace.selected_building != null:
					worldspace.selected_building.selected = false
					worldspace.selected_building = null
				worldspace.selected_leader = self
			else:
				if worldspace.selected_leader != self:
					worldspace.selected_leader.selected = false
				worldspace.selected_leader = null

