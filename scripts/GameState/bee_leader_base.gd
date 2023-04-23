class_name Bee_Leader extends Bee

@export var start : Building
@export var spawn : String
@export var spawn_time : int
@export var spawn_timer : int
@export var ability_time : int
@export var ability_timer : int
@export var ability_desc : String
@export var encounter_move : String
@export var soldier_limit : int

var active : bool = true
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
	worldspace.effect("player_bee_lead_leave", global_position, 0.0)
	if is_instance_valid(current_target):
		current_target.target = null
	queue_free()

func change_enemy(): #for Commanders
	if len(can_see) > 0 and len(squad) > 0:
		match encounter_move:
			"rushdown": #just pick a new one without any thought
				current_enemy = can_see.pick_random()
				var new_target = worldspace.try_attach_target(current_enemy, self, "bee_lead_attack")
				for bee in squad:
					bee.order("push", new_target)
	else: #no enemies in sight
		current_enemy = null

func leader_on_attack(): #ditto
	pass

func ability_available():
	return (ability_time == ability_timer)

func use_ability(): #ditthree
	ability_time = 0
	speed *= 1.5
	health /= 1.5
	for bee in squad:
		bee.speed *= 2
		bee.health /= 1.5

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
	$BeeAbilityBar.value = (float(ability_time)/ability_timer) * 100
	$BeeAbilityBar.visible = ($BeeAbilityBar.value < 100)
	
	$HurtBox.monitorable = active
	$HurtBox.monitoring = active
	$DetectBox.monitorable = active
	$DetectBox.monitoring = active
	input_pickable = active

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

