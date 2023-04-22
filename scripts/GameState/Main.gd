extends Node2D

var player_bee_lead_base : PackedScene = preload("res://scenes/Player/commander/bee_leader_base.tscn")
var target_ret = preload("res://scenes/TargetPosition.tscn")
#@export var player_bee_base : CharacterBody2D

@onready var Bee_Controls = $GUI/Bee_Controls
@onready var Position_Controls = $GUI/Position_Controls

var selected_leader : Bee_Leader
var current_target : Target
var modes = ["View", "Movement Marker"]
var mode = "View"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	create_bee(player_bee_lead_base, true, null)

func random_pos():
	return Vector2(randf() - 0.5, randf() - 0.5) * 100

func create_bee(soldier : PackedScene, is_lead : bool, leader : Bee_Leader):
	var new_bee = soldier.instantiate()
	if !is_lead:
		new_bee.leader = leader
		new_bee.position = leader.position + random_pos()
		new_bee.mode = "follow"
	else:
		new_bee.position = get_viewport_rect().position + get_viewport_rect().size / 2
		new_bee.mode = "hover"
	$GameplayContainer.add_child(new_bee)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Bee_Controls.visible = (selected_leader != null) and (mode == "View")
	Position_Controls.visible = (mode == "Movement Marker")
	if mode == "Movement Marker":
		if current_target.used:
			current_target = null
			mode = "View"

func _on_move_commander_pressed():
	mode = "Movement Marker"
	current_target = target_ret.instantiate()
	$GameplayContainer.add_child(current_target)
	if selected_leader.target:
		selected_leader.target.queue_free()
	selected_leader.target = current_target
	selected_leader.mode = "directed"
	

func _on_try_to_spawn_pressed():
	if selected_leader.spawn_time == selected_leader.spawn_timer:
		selected_leader.spawn_timer = 0
		create_bee(selected_leader.solder, false, selected_leader)
