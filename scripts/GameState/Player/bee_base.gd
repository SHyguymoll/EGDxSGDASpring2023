extends Node2D

@export var health : float = 1.0
@export var atk : float = 0.35
@export var speed : float = 0.5
@export var mode = "hover"
@export var leader : Node2D = null
@export var formation_closeness : float = 10

var target_position : Vector2 = Vector2.ZERO

var active = false
var modes = ["hover", "directed"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func random_pos():
	return Vector2(randf() - 0.5, randf() - 0.5)*(10 - formation_closeness)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		match mode:
			"hover":
				position = lerp(
					position,
					get_viewport().get_mouse_position() + random_pos(),
					speed)
		
	
