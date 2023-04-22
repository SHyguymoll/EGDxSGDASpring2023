extends "res://scripts/GameState/Player/bee_base.gd"

@export var solder : PackedScene
@export var spawn_time : int
var spawn_timer : int


func _physics_process(delta):
	spawn_timer = min(spawn_timer + 1, spawn_time)

func spawn_soldier():
	if spawn_timer == spawn_time:
		spawn_timer = 0
		

var hovered = false
var selected = false

func _on_mouse_entered():
	hovered = true

func _on_mouse_exited():
	hovered = false

func _process(delta):
	$AttackBar.value = (last_atk/atk_speed) * 100
	$AttackBar.visible = true if $AttackBar.value < 100 else false
	$SelectLight.visible = hovered or selected
	$BeeCreateBar.value = (spawn_timer/spawn_time) * 100
	$BeeCreateBar.visible = true if $BeeCreateBar.value < 100 else false

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected = !selected

