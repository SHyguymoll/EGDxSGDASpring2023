class_name Target

extends Node2D

@onready var worldspace : world = get_tree().get_root().get_node("Stage")
var used : bool
var force_delete : bool = true
@onready var movement_completed = false
@export var textures = {
	"move" : "res://art/GUI/Reticles/SelectionReticle.png",
	"bee_lead_attack" : "res://art/GUI/Reticles/AttackReticle.png",
	"bee_solder_attack" : "res://art/GUI/Reticles/SmallAttackReticle.png"
}
@export var texture : String = "move"

var target #assume that this either a Bee, Bee-like, or a Building
var source

func _ready():
	if used: $Bwoop.play()
	$Sprite2D.texture = load(textures[texture])

func _input(event):
	if !used:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				used = true
				source = worldspace.selected_leader
				target = self
				$Bwoop.play()
