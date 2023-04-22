class_name world

extends Node2D

var player_bee_lead_base : PackedScene = preload("res://scenes/Player/commander/bee_leader_base.tscn")
var player_hive : PackedScene = preload("res://scenes/Player/building/Hive.tscn")
var target_ret = preload("res://scenes/TargetPosition.tscn")
#@export var player_bee_base : CharacterBody2D

@onready var Message = $GUI/Message
@onready var Bee_Controls = $GUI/Bee_Controls
@onready var Hive_Controls = $GUI/Hive_Controls
@onready var Position_Controls = $GUI/Position_Controls

var selected_leader : Bee_Leader
var current_target : Target
var selected_building : Building
var hive_placed : bool = false
var modes = ["View", "Movement Marker", "Building Place"]
var mode = "View"

var tutorial : int = 0
var message_bank = [
	"First place a hive.",
	"Next, click on the hive.",
	"Now click 'Do Building Action' to spawn your first Commander Bee.",
	"Each hive can only have one Commander Bee, but each Commander Bee generates bees of their own.\nClick on the Commander Bee.",
	"Click on 'Spawn Bee' once the 'Bee Create' bar disappears.",
	"Now you have a Soldier Bee. Commander Bees automatically use these to fight.\nFighting gets you HP which can be used to level up your Hive and Commander Bee.\nSoldier Bees can perish, but Commander Bees teleport back to their Hive when their health is depleted.\nNow click 'Move Commander'.",
	"Move the Commander Bee however you want.\nYou can't control the Soldiers directly, but Commanders can be maneuvered.\nComplete (or cancel) the movement order to finish this tutorial and start the game."
]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Camera.position = get_viewport_rect().size / 2
	selected_building = player_hive.instantiate()
	$GameplayContainer.add_child(selected_building)
	mode = "Building Place"
	Message.text = "First place a hive"
	Position_Controls.get_node("Label").text = "Press Mouse1 to place."
	#create(player_hive, null, get_viewport_rect().position + get_viewport_rect().size / 2)

func random_pos():
	return Vector2(randf() - 0.5, randf() - 0.5) * 100

#leader could be Bee_Leader or Building
func create(new_thing : PackedScene, leader, pos : Vector2, texture : String):
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
	elif new_thing_inst is Target:
		new_thing_inst.position = pos
		new_thing_inst.used = true
		new_thing_inst.texture = texture
	$GameplayContainer.add_child(new_thing_inst)
	return new_thing_inst

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if mode == "Start Game":
		tutorial = 1
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
	if tutorial != -1:
		Message.text = message_bank[tutorial]
		match tutorial:
			0: if hive_placed: tutorial = 1
			1: if selected_building != null: tutorial = 2
			2: if selected_building.building_data != null: tutorial = 3
			3: if selected_leader != null: tutorial = 4
			4: if len(selected_leader.leader_data.bee) > 0: tutorial = 5
			5: if mode == "Movement Marker": tutorial = 6
			6: if mode == "View": tutorial = -1; Message.text = ""
			

func _on_move_commander_pressed():
	mode = "Movement Marker"
	current_target = target_ret.instantiate()
	current_target.texture = "move"
	$GameplayContainer.add_child(current_target)
	if selected_leader.target != null:
		selected_leader.target.queue_free()
	selected_leader.target = current_target
	selected_leader.mode = "directed"

func _on_try_to_spawn_pressed():
	if selected_leader.spawn_time == selected_leader.spawn_timer:
		selected_leader.spawn_time = 0
		selected_leader.leader_data.bee.append(create(selected_leader.spawn, selected_leader, Vector2.ZERO, ""))

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
