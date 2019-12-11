extends Node2D

var possible_spawners = [ "A", "B", "C", "D", "E" ]
var random_paths      = [ "1", "2" ]
onready var paths     = { }

func _ready():
	var paths_node = get_parent().get_node("Paths")
	for enemy in paths_node.get_children():
		paths[enemy.name] = ""
		for path in enemy.get_children():
			paths[enemy.name] += path.name
	print( paths )

func spawn_obstacle( obstacle_to_spawn ):
	if is_flying( obstacle_to_spawn ): spawn_flying(obstacle_to_spawn)
	else : spawn_ground( obstacle_to_spawn )

func spawn_checkpoint( letter ):
	$Checkpoint_Spawner.spawn( Utilities.get_instance("checkpoint"), letter )

func spawn_reached_checkpoint(letter):
	var instance = Utilities.get_instance("checkpoint")
	instance.is_not_reached = false
	$Checkpoint_Spawner.spawn( instance, letter)
	instance.position.x  = Utilities.player.base_position_x + 150

func spawn_ground(obstacle_to_spawn):
	match obstacle_to_spawn:
		"Rock2" : 
			$Rock_Spawner.spawn( Utilities.get_instance(obstacle_to_spawn) )
		"RockB" : 
			$Rock_Spawner.spawn( Utilities.get_instance(obstacle_to_spawn) )
		"RockS" : 
			$Rock_Spawner.spawn( Utilities.get_instance(obstacle_to_spawn) )
		"Hole" : 
			$Hole_Spawner.spawn( Utilities.get_instance(obstacle_to_spawn) )
		"HoleB" : 
			$Hole_Spawner.spawn( Utilities.get_instance(obstacle_to_spawn) )
		"Mine" : 
			$Mine_Spawner.spawn( Utilities.get_instance(obstacle_to_spawn) )
		"Worm" :
			$Hole_Spawner.spawn( Utilities.get_instance(obstacle_to_spawn) )
		_ :
			assert(true == false)

func is_flying(obstacle):
	return "_" in obstacle

func validate_id(spawner_id, alien_name):
	
	var is_spawner = spawner_id in possible_spawners
	var is_random  = spawner_id in random_paths
	var is_path    = spawner_id in paths[alien_name]
	
	var is_ok = is_path or is_random or is_spawner
	
	if is_ok: return
	else:
		print( "Error : key word '" + spawner_id + "' is unknown for " +  alien_name + " enemy " )   
		assert( is_ok )

func get_random_path(obstacle_name):
	var random_path = paths[obstacle_name][ randi()% len(paths[obstacle_name])] 
	return get_node("/root/Root/Paths/" + obstacle_name + "/" + random_path)

func spawn_flying(enemy):
	var number_of_enemies = int(enemy[0])
	var squat_id = SquatController.register_new_squat(number_of_enemies)
	var squat = []
	var obstacle_name = enemy.right(2 + number_of_enemies + 1)
	for spawner in number_of_enemies:
		var spawner_id = enemy[2 + spawner]
		validate_id(spawner_id, obstacle_name)
		var instance = Utilities.get_instance(obstacle_name)
		squat.append( instance )
		
		if spawner_id in possible_spawners:
			get_node("Alien_Spawner" + spawner_id).spawn(instance, squat_id, number_of_enemies, null )
		elif spawner_id == "1":
			get_node("Alien_Spawner" + possible_spawners[randi()%possible_spawners.size()]).spawn(instance, squat_id, number_of_enemies, null )
		elif spawner_id == "2":
			var path_node = get_random_path(obstacle_name)
			get_node("Alien_SpawnerA").spawn(instance, squat_id, number_of_enemies, path_node)
		else:
			var path_node = get_node("/root/Root/Paths/" + obstacle_name + "/" + spawner_id)
			get_node("Alien_SpawnerA").spawn(instance, squat_id, number_of_enemies, path_node)
		
	SquatController.fill_squat( squat_id, squat, obstacle_name )
