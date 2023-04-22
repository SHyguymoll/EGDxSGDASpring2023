extends Node2D

var player_bee_lead_base : PackedScene = preload("res://scenes/Player/commander/bee_leader_base.tscn")
#@export var player_bee_base : CharacterBody2D

@onready var Bee_Controls = $GUI/Bee_Controls

var selected_leader : Bee_Leader

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	create_bee(player_bee_lead_base, true, null)

func random_pos():
	return Vector2(randf() - 0.5, randf() - 0.5) * 10

func create_bee(soldier : PackedScene, is_lead : bool, leader : Bee_Leader):
	var new_bee = soldier.instantiate()
	if !is_lead:
		new_bee.leader = leader
		new_bee.position = leader.position + random_pos()
	else:
		new_bee.position = get_viewport_rect().size / 2
	$GameplayContainer.add_child(new_bee)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Bee_Controls.visible = (selected_leader != null)
