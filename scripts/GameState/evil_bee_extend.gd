extends Bee
#Evil bee goes directly towards your hive, no need to hover or follow
func handle_death():
	$Animate.anim_state = "Death"
	if leader != null:
		leader.leader_data.bee.erase(self)
		leader = null
	worldspace.honey_points += score_gain
	queue_free()

func post_attack():
	if (atk_time > ((atk_timer / 5) - 1)):
		if $Animate.is_playing() == false:
			$Animate.anim_state = "Idle"

func pick_location(): #no logic to change target based on mode, no need to change target
	target_position = target_position

func post_movement(): #ditto
	target_position = target_position

func _process(_delta): #don't use bars
	worldspace
