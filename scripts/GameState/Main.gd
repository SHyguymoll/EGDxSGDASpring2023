class_name world

extends Node2D

var player_bee_lead_base : PackedScene = preload("res://scenes/Player/commander/bee_leader_base.tscn")
var player_hive : PackedScene = preload("res://scenes/Player/building/Hive.tscn")
var target_ret = preload("res://scenes/TargetPosition.tscn")
var explosion_effect = preload("res://scenes/Effects/explosion.tscn")
#@export var player_bee_base : CharacterBody2D

@onready var Message = $GUI/Message
@onready var Bee_Controls = $GUI/Bee_Controls
@onready var Hive_Controls = $GUI/Hive_Controls
@onready var Position_Controls = $GUI/Position_Controls
@onready var Wave_HUD = $GUI/Wave_HUD

var selected_leader : Bee_Leader
var current_target : Target
var selected_building : Building
var honey_points : int = 0
var hive_placed : bool = false
var modes = ["View", "Movement Marker", "Building Place", "Game Over"]
var game_portions = ["Tutorial", "Pre Wave", "Incoming Enemies", "During Wave", "Game Over"]
var game_portion = "Tutorial"
var wave : int = 0
var enemies_to_spawn : int = 0
var enemies_here = []
var mode = "View"

var tutorial : int = 0
var message_bank = [
	"First place a hive.",
	
	"Next, click on the hive.",
	
	"Now click 'Do Building Action' to spawn your first Commander Bee.",
	
	"Each hive can only have one Commander Bee per levelup, but each Commander Bee generates a number of Soldier bees to lead.
	Click on the Commander Bee.",
	
	"Click on 'Spawn Bee' once the 'Bee Create' bar disappears to spawn a Soldier Bee on the Commander.",
	
	"Now you have a Soldier Bee. Commander Bees automatically use these to fight.
	Winning fights gets you Honey Points which can be used to level up your Hive and Commander Bee.
	Soldier Bees can perish, but Commander Bees teleport back to their Hive when their health is depleted for a small Honey Point fee.
	Now click 'Move Commander'.",
	
	"Move the Commander Bee however you want.
	You can't control the Soldiers directly, but Commanders can be maneuvered.
	Destroy the target to finish this tutorial and start the game."
]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Camera.position = get_viewport_rect().size / 2
	selected_building = player_hive.instantiate()
	$GameplayContainer.add_child(selected_building)
	mode = "Building Place"
	Position_Controls.get_node("Label").text = "Press Mouse1 to place."
	#create(player_hive, null, get_viewport_rect().position + get_viewport_rect().size / 2)

func random_pos():
	return Vector2(randf() - 0.5, randf() - 0.5) * 100

#leader could be Bee_Leader or Building
func create(new_thing : PackedScene, leader, pos : Vector2):
	var new_thing_inst = new_thing.instantiate()
	if new_thing_inst is Bee_Leader:
		new_thing_inst.start = selected_building
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

func attach_target(thing : Node2D, texture : String):
	var new_target : Target = target_ret.instantiate()
	new_target.texture = texture
	new_target.target = thing
	new_target.used = true
	$GameplayContainer.add_child(new_target)
	return new_target

func explosion(pos: Vector2, time : float):
	var new_boom = explosion_effect.instantiate()
	new_boom.start = time
	new_boom.global_position = pos
	$GameplayContainer.add_child(new_boom)

func game_over():
	mode = "Game Over"
	Message.message("Your Hive was destroyed. Game Over.", 5)
	pass

func _physics_process(_delta):
	match game_portion:
		"Tutorial":
			Wave_HUD.hide()
		"Pre Wave":
			Wave_HUD.show()
			Wave_HUD.get_node("CurrentWave").text = "Current Wave: " + str(wave)
			Wave_HUD.get_node("EnemiesLeft").text = "No Enemies, prepare for next wave."
		"Incoming Enemies", "During Wave":
			Wave_HUD.get_node("CurrentWave").text = "Current Wave: " + str(wave)
			Wave_HUD.get_node("EnemiesLeft").text = str(len(enemies_here)) + "/" + str(enemies_to_spawn)
		"Game Over":
			Wave_HUD.get_node("CurrentWave").text = "Final Wave: " + str(wave)
			Wave_HUD.get_node("EnemiesLeft").text = str(len(enemies_here)) + "/" + str(enemies_to_spawn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if mode == "Start Game":
		tutorial = 1
		$GUI/Position_Controls/Label.text = "Press Mouse1 to place, or press Backspace to cancel."
		mode = "View"
	Bee_Controls.visible = (selected_leader != null) and (mode == "View")
	Hive_Controls.visible = (selected_building != null) and (mode == "View")
	if selected_building != null:
		Hive_Controls.get_node("LevelBuilding").text = "Level Up Building (cost: {0})".format([selected_building.level_cost])
		Hive_Controls.get_node("LevelBuilding").visible = (Hive_Controls.visible) and (selected_building.level_cost != 9223372036854775807)
		Hive_Controls.get_node("DestroyBuilding").visible = (Hive_Controls.visible) and (selected_building.building_name != "Hive")
	
	Position_Controls.visible = (mode == "Movement Marker") or (mode == "Building Place")
	
	match mode:
		"Movement Marker":
			if current_target.used:
				current_target = null
				mode = "View"
			if Input.is_action_pressed("Cancel"):
				selected_leader.mode = "hover"
				current_target.queue_free()
				mode = "View"
		"Building Place":
			if Input.is_action_pressed("Cancel"):
				selected_building.queue_free()
				selected_building = null
				mode = "View"
		"Game Over":
			if !Message.visible:
				get_tree().reload_current_scene()
	if tutorial != -1:
		Message.message(message_bank[tutorial], -1.0)
		match tutorial:
			0: if hive_placed: tutorial = 1
			1: if selected_building != null: tutorial = 2
			2: if len(selected_building.building_data.bees) != 0: tutorial = 3
			3: if selected_leader != null: tutorial = 4
			4: if selected_leader != null and len(selected_leader.leader_data.bee) > 0: tutorial = 5
			5: if mode == "Movement Marker": tutorial = 6
			6: if $GameplayContainer.get_node_or_null("Target") == null: tutorial = -1; Message.message("", 0)

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
		if len(selected_leader.leader_data.bee) <= selected_leader.soldier_limit:
			selected_leader.spawn_time = 0
			selected_leader.leader_data.bee.append(create(load(selected_leader.spawn), selected_leader, Vector2.ZERO))
		else:
			Message.text = "Commander reached bee limit"
	else:
		Message.text = "Commander can't create a bee yet"
		
	
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
	if honey_points >= selected_building.level_cost:
		honey_points -= selected_building.level_cost
		selected_building.level_building(selected_building.level + 1)
		
