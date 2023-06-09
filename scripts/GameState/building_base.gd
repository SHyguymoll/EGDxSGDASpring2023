class_name Building
extends StaticBody2D

@onready var level = 0
const level_costs = [10, 30, 9223372036854775807] #lmao
var level_cost
@export var spawn_time : int
@export var spawn_timer : int
@export var health : float
@export var health_max : float
@export var building_name : String
@export var team : String
@export var create : PackedScene

@onready var worldspace = get_tree().get_root().get_node("Stage")

var commanders : Array[Bee] = []

var placed = false
var hovered = false
var selected = false

func random_pos():
	return Vector2(randf() - 0.5, randf() - 0.5) * 100

func tick_timers():
	spawn_time = min(spawn_time + 1, spawn_timer)
	health = min(health + 0.001*(level), health_max)

func try_sound(node_name : String):
	if $Sounds.get_node_or_null(node_name) != null:
		$Sounds.get_node(node_name).play()

func _on_mouse_entered():
	hovered = true and placed

func _on_mouse_exited():
	hovered = false and placed

func _process(_delta):
	if !placed:
		position = get_global_mouse_position()
	@warning_ignore("integer_division")
	$ActionBar.value = float(spawn_time)/spawn_timer * 100
	$ActionBar.visible = ($ActionBar.value < 100)
	$HealthBar.value = float(health)/health_max * 100
	$HealthBar.visible = ($HealthBar.value < 100)
	$SelectLight.visible = hovered or selected
	level_cost = level_costs[level]

func handle_destroy():
	for n in range(3): worldspace.effect("explosion", global_position + random_pos(), 0.15 * n)
	for lead in commanders:
		if !is_instance_valid(lead):
			continue
		for bee in lead.squad:
			bee.health = -10
		lead.health = -10
	worldspace.game_over()
	queue_free()

func pain(dmg: float, _accuracy: float):
	try_sound("Hit")
	health -= dmg

func ability_available():
	return (len(commanders) <= level) and (spawn_time == spawn_timer) and (worldspace.honey_points >= 5)

func use_ability():
	worldspace.honey_points -= 5
	worldspace.spawn_player_bee(create, null, self, global_position)
	spawn_time = 0

func use_passive():
	if Input.is_action_just_pressed("debugKILL"):
		pain(2 * health, 1)

func level_building(new_val : int):
	try_sound("LevelUp")
	level = new_val
	$Sprite2D.frame = new_val

func placed_action():
	worldspace.hive_placed = global_position
	worldspace.mode = "Start Game"

func _input(event):
	if !placed:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				placed = true
				worldspace.selected_building = null
				placed_action()
	else:
		if event is InputEventMouseButton and hovered:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				selected = !selected
				if selected:
					if worldspace.selected_building != self and worldspace.selected_building != null:
						worldspace.selected_building.selected = false
					if worldspace.selected_leader != null:
						worldspace.selected_leader.selected = false
						worldspace.selected_leader = null
					worldspace.selected_building = self
				else:
					if worldspace.selected_building != self:
						worldspace.selected_building.selected = false
					worldspace.selected_building = null
