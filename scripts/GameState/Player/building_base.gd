class_name Building

extends StaticBody2D

@onready var level = 0
@export var spawn_time : int
@export var spawn_timer : int
@export var health : float
@export var building_name : String

@onready var worldspace = get_tree().get_root().get_node("Stage")

var hovered = false
var selected = false

func _on_mouse_entered():
	hovered = true

func _on_mouse_exited():
	hovered = false

func _process(_delta):
	@warning_ignore("integer_division")
	$ActionBar.value = (spawn_time/spawn_timer) * 100
	$ActionBar.visible = ($ActionBar.value < 100)
	$SelectLight.visible = hovered or selected

func destroy():
	pass

func pain(dmg: float, accuracy: float):
	health -= dmg
	if health <= 0:
		destroy()

func use_ability():
	pass

func level_building(new_val : int):
	level = new_val
	$Sprite2D.frame = new_val

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and hovered:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected = !selected
			if selected:
				if worldspace.selected_building != self and worldspace.selected_building != null:
					worldspace.selected_building.selected = false
				worldspace.selected_building = self
			else:
				if worldspace.selected_building != self:
					worldspace.selected_building.selected = false
				worldspace.selected_building = null
