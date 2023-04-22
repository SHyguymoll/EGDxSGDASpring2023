class_name Target

extends Node2D

@onready var worldspace : world = get_tree().get_root().get_node("Stage")
var used
@onready var movement_completed = false
@export var textures = {
	"move" : "res://art/GUI/Reticles/SelectionReticle.png",
	"bee_lead_attack" : "res://art/GUI/Reticles/AttackReticle.png",
	"bee_solder_attack" : "res://art/GUI/Reticles/SmallAttackReticle.png"
}
@export var texture : String = "move"

var target #assume that this either a Bee, child of Bee, or a Building, as all of these have health.

func _ready():
	$Sprite2D.texture = load(textures[texture])

func _process(_delta):
	if !used:
		global_position = get_global_mouse_position()
	else:
		if target.is_queued_for_deletion():
			queue_free()
#		if (target is Bee) or (target is Building):
#			if target.health == null:
#
#		else:
#			if movement_completed:
#				queue_free()
		global_position = target.global_position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			used = true
			target = self
