extends Node2D

var player_bee_lead_base : PackedScene = preload("res://scenes/Player/commander/bee_leader_base.tscn")
var player_hive : PackedScene = preload("res://scenes/Player/building/Hive.tscn")
var target_ret = preload("res://scenes/TargetPosition.tscn")
#@export var player_bee_base : CharacterBody2D

@onready var Bee_Controls = $GUI/Bee_Controls
@onready var Hive_Controls = $GUI/Hive_Controls
@onready var Position_Controls = $GUI/Position_Controls

var selected_leader : Bee_Leader
var current_target : Target
var selected_building : Building
var modes = ["View", "Movement Marker", "Building Place"]
var mode = "View"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Camera.position = get_viewport_rect().size / 2
	selected_building = player_hive.instantiate()
	$GameplayContainer.add_child(selected_building)
	mode = "Building Place"
	$GUI/Position_Controls/Label.text = "Press Mouse1 to place."
	#create(player_hive, null, get_viewport_rect().position + get_viewport_rect().size / 2)

func random_pos():
	return Vector2(randf() - 0.5, randf() - 0.5) * 100

#leader could be Bee_Leader or Building
func create(new_thing : PackedScene, leader, pos : Vector2):
	var new_thing_inst = new_thing.instantiate()
	if new_thing_inst is Bee_Leader:
		new_thing_inst.position = pos
		new_thing_inst.mode = "hover"
	elif new_thing_inst is Bee:
		new_thing_inst.leader = leader
		new_thing_inst.position = leader.position + random_pos()
		new_thing_inst.mode = "follow"
	elif new_thing_inst is Building:
		new_thing_inst.position = pos
		new_thing_inst.level = 0
	$GameplayContainer.add_child(new_thing_inst)
	return new_thing_inst

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if mode == "Start Game":
		$GUI/Position_Controls/Label.text = "Press Mouse1 to place, or press Backspace to cancel."
		mode = "View"
	Bee_Controls.visible = (selected_leader != null) and (mode == "View")
	Hive_Controls.visible = (selected_building != null) and (mode == "View")
	Position_Controls.visible = (mode == "Movement Marker") or (mode == "Building Place")
	if mode == "Movement Marker":
		if current_target.used:
			current_target = null
			mode = "View"
		if Input.is_action_pressed("Cancel"):
			selected_leader.mode = "hover"
			current_target.queue_free()
			mode = "View"
	if mode == "Building Place":
		if Input.is_action_pressed("Cancel"):
			selected_building.queue_free()
			selected_building = null
			mode = "View"

func _on_move_commander_pressed():
	mode = "Movement Marker"
	current_target = target_ret.instantiate()
	$GameplayContainer.add_child(current_target)
	if selected_leader.target != null:
		selected_leader.target.queue_free()
	selected_leader.target = current_target
	selected_leader.mode = "directed"

func _on_try_to_spawn_pressed():
	if selected_leader.spawn_time == selected_leader.spawn_timer:
		selected_leader.spawn_time = 0
		create(selected_leader.spawn, selected_leader, Vector2.ZERO)

func _on_use_ability_pressed():
	if selected_leader.ability_time == selected_leader.ability_timer:
		selected_leader.ability_time = 0
		selected_leader.use_ability()

func _on_building_action_pressed():
	if selected_building.spawn_time == selected_building.spawn_timer:
		selected_building.spawn_time = 0
		selected_building.use_ability()

func _on_destroy_building_pressed():
	if selected_building.building_name != "Hive":
		selected_building.destroy()

func _on_level_building_pressed():
	pass # Replace with function body.
