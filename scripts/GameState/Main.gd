class_name world

extends Node2D

var player_bee_lead_base : PackedScene = preload("res://scenes/Player/bee_leader_base.tscn")
var player_hive : PackedScene = preload("res://scenes/Player/Hive.tscn")

var enemy_base : PackedScene = preload("res://scenes/Enemies/evil_bee_normal.tscn")

var target_ret = preload("res://scenes/TargetPosition.tscn")

var effects = {
	"explosion": preload("res://scenes/Effects/explosion.tscn"),
	"player_bee_lead_leave": preload("res://scenes/Effects/leader_bee_base_knockout.tscn"),
	"enemy_bee_death": preload("res://scenes/Effects/enemy_bee_death.tscn"),
	"player_bee_death": preload("res://scenes/Effects/player_bee_death.tscn")
}

var game_started = false

@onready var Message = $GUI/Message
@onready var Bee_Controls = $GUI/Bee_Controls
@onready var Hive_Controls = $GUI/Hive_Controls
@onready var Position_Controls = $GUI/Position_Controls
@onready var Wave_HUD = $GUI/Wave_HUD

var player_bees : Array[Bee] = []
var player_builds : Array[Building] = []

var enemy_bees : Array[Bee] = []
var enemy_builds : Array[Building] = []
var enemy_total : int = 0

var targets : Array[Target] = [] #All of the targets on the screen

var game_portion = "Tutorial"
var wave : int = 0
var time_till_next_wave : int = -1

var selected_leader : Bee_Leader #A leader that the player has selected, mutually exclusive with selected_building
var selected_building : Building #A building that the player has selected, mutually exclusive with selected_leader
var current_target : Target #A target that the player is manipulating
var honey_points : int = 5
var hive_placed : Vector2 = Vector2.ZERO
var modes = ["View", "Movement Marker", "Building Place", "Game Over"]
var game_portions = ["Tutorial", "Pre Wave", "Incoming Enemies", "During Wave", "Game Over"]

var mode = "View"

var tutorial : int = 0
var message_bank = [
	"First, place the hive.
	You must protect this building as long as possible.",
	
	"Next, click on the hive.",
	
	"Now click 'Do Building Action' to spawn your first Commander Bee.",
	
	"Each hive can only have one Commander Bee per levelup,
	but each Commander Bee generates a number of Soldier bees to lead.
	This number increases with the level of the hive.
	Click on the Commander Bee.",
	
	"Commander Bees automatically use Solder Bees to fight.
	Winning fights gets you Honey Points which can be used to level up your Hive.
	Soldier Bees can perish, but Commander Bees teleport back to their Hive
	when their health is depleted for a small Honey Point fee.
	Now click 'Move Commander'.",
	
	"Move the Commander Bee however you want.
	You can't control the Soldiers directly, but Commanders can be maneuvered.
	Destroy the target to finish this tutorial and start the game."
]

func _on_start_game_pressed():
	game_started = true
	$Menu.queue_free()
	enemy_bees.append($GameplayContainer/Target)
	selected_building = player_hive.instantiate()
	player_builds.append(selected_building)
	$GameplayContainer.add_child(selected_building)
	mode = "Building Place"
	Position_Controls.get_node("Label").text = "Press Mouse1 to place."


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Camera.position = get_viewport_rect().size / 2

func random_pos():
	return Vector2(randf() - 0.5, randf() - 0.5) * 100

func spawn_player_bee(bee_scene : PackedScene, leader : Bee_Leader, building : Building, pos : Vector2):
	var new_bee : Bee = bee_scene.instantiate()
	new_bee.global_position = pos
	if new_bee is Bee_Leader:
		new_bee.start = building
		building.commanders.append(new_bee)
		new_bee.mode = "hover"
	elif new_bee is Bee:
		new_bee.leader = leader
		leader.squad.append(new_bee)
		new_bee.mode = "follow"
	player_bees.append(new_bee)
	$GameplayContainer.add_child(new_bee)

func spawn_enemy_bee(bee_scene : PackedScene, pos : Vector2):
	var new_bee : Bee = bee_scene.instantiate()
	new_bee.global_position = pos
	new_bee.target_position = player_builds[0].global_position #always the hive
	new_bee.mode = "directed"
	
	#values here determined at 5:37 AM, 4/23/23
	new_bee.health *= 1 + (float(wave)/5)
	new_bee.health_max *= 1 + (float(wave)/5)
	new_bee.atk *= 1 + (float(wave)/6)
	new_bee.atk_timer /= 1 + (float(wave)/10)
	new_bee.speed *= 1 + (float(wave)/3)
	new_bee.accuracy *= 1 + (float(wave)/2)
	new_bee.score_gain *= 1 + (float(wave)/5)
	
	enemy_bees.append(new_bee)
	$GameplayContainer.add_child(new_bee)

func spawn_player_build(build_scene : PackedScene, pos : Vector2):
	var new_build : Building = build_scene.instantiate()
	new_build.global_position = pos
	player_builds.append(new_build)
	$GameplayContainer.add_child(new_build)

func try_attach_target(to_target : Node2D, from_source : Node2D, texture : String):
	for tar in targets:
		if tar.target == to_target:
			return
	return attach_target(to_target, from_source, texture)

func attach_target(to_target : Node2D, from_source : Node2D, texture : String):
	var new_target : Target = target_ret.instantiate()
	new_target.texture = texture
	new_target.target = to_target
	new_target.source = from_source
	new_target.used = true
	targets.append(new_target)
	$GameplayContainer.add_child(new_target)
	return new_target

func effect(effect_name : String, pos: Vector2, time : float):
	var new_effect = effects[effect_name].instantiate()
	new_effect.start = time
	new_effect.global_position = pos
	$GameplayContainer.add_child(new_effect)

func game_over():
	mode = "Game Over"
	Message.message("Your Hive was destroyed. Game Over.", 5)

func pick_coord_outside_view():
	if randf() >= 0.5: #top
		if randf() >= 0.5: #left
			return get_viewport_rect().get_center() - Vector2(randi_range(1280, 1300), randi_range(760, 780))
		else: #right
			return get_viewport_rect().get_center() - Vector2(randi_range(-1280, -1300), randi_range(760, 780))
	else: #bottom
		if randf() >= 0.5: #left
			return get_viewport_rect().get_center() - Vector2(randi_range(1280, 1300), randi_range(-760, -780))
		else: #right
			return get_viewport_rect().get_center() - Vector2(randi_range(-1280, -1300), randi_range(-760, -780))

func spawn_enemies(): #this is done all at once
	enemy_total = 0
	for n in range(3*(wave + 1)): #basic bee
		spawn_enemy_bee(enemy_base, pick_coord_outside_view())
		enemy_total += 1
	if wave > 5: #pesticider
		for n in range((wave - 4) * 1.2):
			pass
#			enemies_here.append()
#			enemies_to_spawn += 1

func handle_game_portion():
	match game_portion:
		"Tutorial":
			Wave_HUD.hide()
		"Pre Wave":
			Wave_HUD.show()
			Wave_HUD.get_node("CurrentWave").text = "Next Wave: " + str(wave + 1)
			Wave_HUD.get_node("EnemiesLeft").text = "No Enemies, prepare for next wave."
			time_till_next_wave = max(time_till_next_wave - 1, 0)
			if time_till_next_wave == 0:
				game_portion = "Incoming Enemies"
		"Incoming Enemies":
			spawn_enemies()
			Wave_HUD.get_node("CurrentWave").text = "Current Wave: " + str(wave + 1)
			Wave_HUD.get_node("EnemiesLeft").text = str(len(enemy_bees)) + "/" + str(enemy_total)
			game_portion = "During Wave"
		"During Wave":
			Wave_HUD.get_node("CurrentWave").text = "Current Wave: " + str(wave + 1)
			Wave_HUD.get_node("EnemiesLeft").text = str(len(enemy_bees)) + "/" + str(enemy_total)
			if len(enemy_bees) + len(enemy_builds) == 0:
				wave += 1
				@warning_ignore("narrowing_conversion")
				time_till_next_wave = 600/(wave * 0.75)
				game_portion = "Pre Wave"
		"Game Over":
			Wave_HUD.get_node("CurrentWave").text = "Final Wave: " + str(wave + 1)
			Wave_HUD.get_node("EnemiesLeft").text = str(len(enemy_bees)) + "/" + str(enemy_total)

const COMPLETION_RANGE = 10

func movement(bees : Array[Bee]):
	for bee in bees:
		if !(bee.mode in ["follow", "hover", "directed"]): #skip attacking and dying bees
			continue
		bee.pick_location()
		if bee.global_position.distance_to(bee.target_position) > COMPLETION_RANGE: #time to move these
			bee.move_bee_towards_target()
			if bee.global_position.distance_to(bee.target_position) < COMPLETION_RANGE:
				if bee.mode == "directed":
					bee.current_target.movement_completed = true
				bee.mode = "hover"
		bee.detect_enemies()
		if !(bee.current_enemy in bee.can_see): #detecting new enemy
			bee.change_enemy()

func attacks(bees):
	for bee in bees:
		if (bee.mode in ["post_attack", "death"]): #only bees that can attack
			continue
		if len(bee.can_hurt) > 0:
			bee.mode = "attack"
		if bee.mode == "attack": #fight time
			bee.attack_enemy()
			bee.mode = "post_attack"

func deaths(bees : Array[Bee]):
	var new_bees : Array[Bee] = []
	for bee in bees:
		if bee.health > 0:
			new_bees.append(bee)
			continue
		effect("explosion", bee.global_position, 0.0)
		bee.handle_death()
	return new_bees

func destroys(builds : Array[Building]):
	var new_builds : Array[Building] = []
	for build in builds:
		if build.health > 0:
			new_builds.append(build)
			continue
		build.handle_destroy()
	return new_builds

func buildings(builds : Array[Building]):
	for build in builds:
		build.use_passive()
		build.tick_timers()

func passives(bees):
	for bee in bees:
		bee.tick_timers()
		if bee is Bee_Leader:
			if bee.spawn_time == bee.spawn_timer and len(bee.squad) <= bee.soldier_limit:
				bee.spawn_time = 0
				spawn_player_bee(load(bee.spawn), bee, null, bee.global_position)

func player_turn():
	movement(player_bees)
	attacks(player_bees)
	enemy_builds = destroys(enemy_builds)
	enemy_bees = deaths(enemy_bees)
	buildings(player_builds)
	passives(player_bees)

func enemy_turn():
	movement(enemy_bees)
	attacks(enemy_bees)
	player_builds = destroys(player_builds)
	player_bees = deaths(player_bees)
	buildings(enemy_builds)
	passives(enemy_bees)

func handle_targets():
	var ref_list : Array[Target] = []
	for tar in targets:
		if tar.movement_completed:
			tar.queue_free()
			continue
		ref_list.append(tar)
		if !tar.used:
			tar.global_position = get_global_mouse_position()
			continue
		else:
			if is_instance_valid(tar.target) and is_instance_valid(tar.source) and tar.target != null:
				tar.source.mode = "directed"
				tar.global_position = tar.target.global_position
			else:
				ref_list.erase(tar)
				tar.queue_free()
				continue
		if tar.source is Bee and !(tar.source is Bee_Leader):
			tar.source.mode = "directed"
			tar.source.current_target = tar
	targets = ref_list

func _physics_process(_delta):
	if !game_started: return
	handle_game_portion()
	player_turn()
	enemy_turn()
	handle_targets()

func handle_tutorial():
	Message.message(message_bank[tutorial], -1.0)
	match tutorial:
		0: if hive_placed: tutorial = 1
		1: if selected_building != null: tutorial = 2
		2: if len(selected_building.commanders) != 0: tutorial = 3
		3: if selected_leader != null: tutorial = 4
		4: if mode == "Movement Marker": tutorial = 5
		5: if $GameplayContainer.get_node_or_null("Target") == null:
			tutorial = -1
			Message.message("", 0)
			time_till_next_wave = 0
			$BackgroundMusic.play()
			game_portion = "Pre Wave"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !game_started: return
	if mode == "Start Game":
		tutorial = 1
		$GUI/Position_Controls/Label.text = "Press Mouse1 to place, or press Backspace to cancel."
		mode = "View"
	$GUI/Score.text = "Score: " + str(honey_points)
	Bee_Controls.visible = (selected_leader != null) and (mode == "View")
	Bee_Controls.get_node("UseAbility").text = ("Use Ability: " + selected_leader.ability_desc) if selected_leader != null else "Use Ability"
	Hive_Controls.visible = (selected_building != null) and (mode == "View")
	if selected_building != null:
		Hive_Controls.get_node("LevelBuilding").text = "Level Up Building (cost: {0})".format([selected_building.level_cost])
		Hive_Controls.get_node("LevelBuilding").visible = (Hive_Controls.visible) and (selected_building.level_cost != 9223372036854775807)
		Hive_Controls.get_node("DestroyBuilding").visible = (Hive_Controls.visible) and (selected_building.building_name != "Hive")
	Position_Controls.visible = (mode == "Movement Marker") or (mode == "Building Place")
	
	match mode:
		"Movement Marker":
			if !is_instance_valid(current_target):
				current_target = null
			if current_target.used:
				current_target = null
				mode = "View"
			if Input.is_action_pressed("Cancel"):
				selected_leader.mode = "hover"
				targets.erase(current_target)
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
		handle_tutorial()

func _on_move_commander_pressed():
	mode = "Movement Marker"
	if selected_leader.current_target != null:
		targets.erase(selected_leader.current_target)
		selected_leader.current_target.queue_free()
	current_target = target_ret.instantiate()
	current_target.texture = "move"
	current_target.used = false
	targets.append(current_target)
	$GameplayContainer.add_child(current_target)
	selected_leader.current_target = current_target
	selected_leader.mode = "hover"

func _on_use_ability_pressed():
	if selected_leader.ability_available():
		Bee_Controls.get_node("UseAbility/Success").play()
		selected_leader.use_ability()
	else:
		Bee_Controls.get_node("UseAbility/Denied").play()

func _on_building_action_pressed():
	if selected_building.ability_available():
		selected_building.use_ability()
	else:
		Hive_Controls.get_node("BuildingAction/Denied").play()

func _on_destroy_building_pressed():
	if selected_building.building_name != "Hive":
		selected_building.destroy()

func _on_level_building_pressed():
	if honey_points >= selected_building.level_cost:
		honey_points -= selected_building.level_cost
		Hive_Controls.get_node("LevelBuilding/Success").play()
		selected_building.level_building(selected_building.level + 1)
	else:
		Hive_Controls.get_node("LevelBuilding/Denied").play()
