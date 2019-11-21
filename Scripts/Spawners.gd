extends Node2D


onready var obstacles = {
	"Hole"  :  load( "res://Scenes/Hole.tscn" ),
	"HoleB" :  load( "res://Scenes/HugeHole.tscn" ),
	"Worm"  :  load( "res://Scenes/WormHole.tscn" ),
	"RockB" :  load( "res://Scenes/Rock.tscn" ),
	"RockS" :  load( "res://Scenes/SmallRock.tscn" ),
	"Mine"  :  load( "res://Scenes/Mine.tscn" ),
	"checkpoint":  load( "res://Scenes/Checkpoint.tscn" ),
	"Alien1"    :  load( "res://Scenes/Alien1.tscn" ),
}

func spawn_obstacle( obstacle_to_spawn ):
	if is_flying( obstacle_to_spawn ): spawn_flying(obstacle_to_spawn)
	else : spawn_ground( obstacle_to_spawn )

func spawn_checkpoint( letter ):
	$Checkpoint_Spawner.spawn( obstacles["checkpoint"].instance(), letter )

func spawn_ground(obstacle_to_spawn):
	match obstacle_to_spawn:
		"RockB" : 
			$Rock_Spawner.spawn( obstacles[obstacle_to_spawn].instance() )
		"RockS" : 
			$Rock_Spawner.spawn( obstacles[obstacle_to_spawn].instance() )
		"Hole" : 
			$Hole_Spawner.spawn( obstacles[obstacle_to_spawn].instance() )
		"HoleB" : 
			$Hole_Spawner.spawn( obstacles[obstacle_to_spawn].instance() )
		"Mine" : 
			$Mine_Spawner.spawn( obstacles[obstacle_to_spawn].instance() )
		"Worm" :
			$Hole_Spawner.spawn( obstacles[obstacle_to_spawn].instance() )
		_ :
			assert(true == false)

func is_flying(obstacle):
	return "_" in obstacle

func spawn_flying(enemy):
	var number_of_enemies = int(enemy[0])
	var squat_id = get_parent().register_new_squat(number_of_enemies)
	for spawner in number_of_enemies:
		var spawner_id = enemy[2 + spawner]
		assert( spawner_id in [ "A", "B", "C", "D", "E" ] )
		var instance = obstacles[enemy.right(2 + number_of_enemies + 1)].instance()
		get_node("Alien_Spawner" + spawner_id).spawn(instance, squat_id, number_of_enemies)
		