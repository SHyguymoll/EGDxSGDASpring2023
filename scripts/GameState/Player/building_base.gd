class_name Building

extends StaticBody2D

@onready var level = 0
const level_costs = [50, 100, 9223372036854775807] #lmao
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
	health = min(health + 0.1*(level+1), health_max)

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
	if Input.is_action_just_pressed("debugKILL"):
		pain(health, 1)

func handle_destroy():
	for n in range(4): worldspace.explosion(global_position + random_pos(), 0.15 * n)
	for lead in commanders:
		for bee in lead.squad:
			bee.pain(bee.health, 1)
		lead.pain(lead.health, 1)
	worldspace.game_over()

func pain(dmg: float, _accuracy: float):
	health -= dmg

func use_ability():
	if len(commanders) <= level:
		worldspace.spawn_player_bee(create, null, self, global_position)

func level_building(new_val : int):
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
