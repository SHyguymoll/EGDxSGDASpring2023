class_name Target

extends Node2D

@onready var worldspace = get_tree().get_root().get_node("Stage")
@onready var used = false
@onready var movement_completed = false
@export var textures = {
	"move" : "res://art/GUI/Reticles/SelectionReticle.png",
	"bee_lead_attack" : "res://art/GUI/Reticles/AttackReticle.png",
	"bee_solder_attack" : "res://art/GUI/Reticles/SmallAttackReticle.png"
}
@onready var texture : String

func _ready():
	$Sprite2D.texture = load(textures[texture])

func _process(_delta):
	if !used:
		position = get_global_mouse_position()
	if used and movement_completed:
		queue_free()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			used = true
			print(get_global_mouse_position())
