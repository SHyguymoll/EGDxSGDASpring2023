extends Node2D

var player_bee_lead_base : PackedScene = preload("res://scenes/Player/commander/bee_leader_base.tscn")
#@export var player_bee_base : CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	


func create_bee(soldier : PackedScene, leader):
	var new_bee = soldier.instantiate()
	new_bee
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
