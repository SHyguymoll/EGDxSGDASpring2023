class_name Bee_Leader extends "res://scripts/GameState/Player/bee_base.gd"

@export var start : Building
@export var spawn : PackedScene
@export var spawn_time : int
@export var spawn_timer : int
@export var ability_time : int
@export var ability_timer : int
@export var encounter_move : String
@onready var worldspace = get_tree().get_root().get_node("Stage")
var target_icon = preload("res://scenes/TargetPosition.tscn")

var current_target

var leader_data : Dictionary = {
	"bee": [],
	"other": []
}
var hovered = false
var selected = false

func tickTimers():
	atk_time = min(atk_time + 1, atk_timer)
	spawn_time = min(spawn_time + 1, spawn_timer)
	ability_time = min(ability_time + 1, ability_timer)

func handle_death(): #Legends never die
	if $Animate.is_playing() == false:
		position = start.position

func _on_detect_box_area_entered(area):
	match encounter_move:
		"rushdown":
			current_target = worldspace.create(target_icon, null, area.global_position, "bee_lead_attack")
			#worldspace.attach(current_target, area.get_parent())
			for bee in leader_data.bee:
				bee.target = current_target
				bee.mode = "directed"

func _on_detect_box_area_exited(area):
	if current_target.global_position == area.global_position:
		current_target = null

func use_ability():
	pass

func _on_mouse_entered():
	hovered = true

func _on_mouse_exited():
	hovered = false

func _process(_delta):
	@warning_ignore("integer_division")
	$AttackBar.value = (atk_time/atk_timer) * 100
	$AttackBar.visible = ($AttackBar.value < 100)
	$SelectLight.visible = hovered or selected
	@warning_ignore("integer_division")
	$BeeCreateBar.value = (float(spawn_time)/spawn_timer) * 100
	$BeeCreateBar.visible = ($BeeCreateBar.value < 100)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and hovered:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected = !selected
			if selected:
				if worldspace.selected_leader != self and worldspace.selected_leader != null:
					worldspace.selected_leader.selected = false
				if worldspace.selected_building != null:
					worldspace.selected_building.selected = false
					worldspace.selected_building = null
				worldspace.selected_leader = self
			else:
				if worldspace.selected_leader != self:
					worldspace.selected_leader.selected = false
				worldspace.selected_leader = null

