extends Bee
#Evil bee goes directly towards your hive, no need to hover or follow
func handle_death():
	if leader != null:
		leader.leader_data.bee.erase(self)
		leader = null
	if $Animate.is_playing() == false:
		worldspace.explosion(global_position + random_pos(), 0.0)
		worldspace.enemies_here.remove(self)
		worldspace.honey_points += score_gain
		queue_free()

func post_attack():
	if (atk_time > ((atk_timer / 5) - 1)):
		mode = "directed"
		if $Animate.is_playing() == false:
			$Animate.anim_state = "Idle"

func pick_location(): #no logic to change target based on mode, no need to change target
	target_position = target_position

func _process(_delta): #don't use bars
	worldspace
