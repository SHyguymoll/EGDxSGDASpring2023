class_name Target

extends Node2D

@onready var worldspace = get_tree().get_root().get_node("Stage")
@onready var used = false
@onready var movement_completed = false

func _process(_delta):
	if !used:
		position = get_global_mouse_position()
	if used and movement_completed:
		queue_free()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			used = true
