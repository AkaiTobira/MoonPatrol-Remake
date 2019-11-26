extends Node2D

func spawn_obstacle( obstacle_to_spawn ):
	if is_flying( obstacle_to_spawn ): spawn_flying(obstacle_to_spawn)
	else : spawn_ground( obstacle_to_spawn )

func spawn_checkpoint( letter ):
	$Checkpoint_Spawner.spawn( Common.get_instance("checkpoint"), letter )

func spawn_reached_checkpoint(letter):
	var instance = Common.get_instance("checkpoint")
	instance.is_not_reached = false
	$Checkpoint_Spawner.spawn( instance, letter)
	instance.position.x  = Common.player.base_position_x + 150

func spawn_ground(obstacle_to_spawn):
	match obstacle_to_spawn:
		"RockB" : 
			$Rock_Spawner.spawn( Common.get_instance(obstacle_to_spawn) )
		"RockS" : 
			$Rock_Spawner.spawn( Common.get_instance(obstacle_to_spawn) )
		"Hole" : 
			$Hole_Spawner.spawn( Common.get_instance(obstacle_to_spawn) )
		"HoleB" : 
			$Hole_Spawner.spawn( Common.get_instance(obstacle_to_spawn) )
		"Mine" : 
			$Mine_Spawner.spawn( Common.get_instance(obstacle_to_spawn) )
		"Worm" :
			$Hole_Spawner.spawn( Common.get_instance(obstacle_to_spawn) )
		_ :
			assert(true == false)

func is_flying(obstacle):
	return "_" in obstacle

func spawn_flying(enemy):
	var number_of_enemies = int(enemy[0])
	var squat_controller = get_parent().get_node("Squat_controller")
	var squat_id = squat_controller.register_new_squat(number_of_enemies)
	var squat = []
	var obstacle_name = enemy.right(2 + number_of_enemies + 1)
	for spawner in number_of_enemies:
		var spawner_id = enemy[2 + spawner]
		assert( spawner_id in [ "A", "B", "C", "D", "E" ] )
		var instance = Common.get_instance(obstacle_name)
		squat.append( instance )
		get_node("Alien_Spawner" + spawner_id).spawn(instance, squat_id, number_of_enemies)
	squat_controller.fill_squat( squat_id, squat, obstacle_name )
