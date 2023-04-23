extends Bee
#Evil bee goes directly towards your hive, no need to hover or follow
func handle_death():
	worldspace.effect("enemy_bee_death", global_position, 0.0)
	if leader != null:
		leader.leader_data.bee.erase(self)
		leader = null
	worldspace.honey_points += score_gain
	queue_free()

func pick_location(): #no logic to change target based on mode, no need to change target
	target_position = target_position

func post_movement(): #ditto
	target_position = target_position

func _process(_delta): #don't use bars
	worldspace
