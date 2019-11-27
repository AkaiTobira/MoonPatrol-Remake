extends Node

var level_jsons = {} 

var sqgment_id = 1
var level_json = {}
var level_list = []

onready var player = get_node( "/root/Root/Player" )

var objects = {
	"Hole"       :  preload( "res://Scenes/Obstacles/Hole.tscn" ),
	"HoleB"      :  preload( "res://Scenes/Obstacles/HugeHole.tscn" ),
	"Worm"       :  preload( "res://Scenes/Obstacles/WormHole.tscn" ),
	"RockB"      :  preload( "res://Scenes/Obstacles/Rock.tscn" ),
	"RockS"      :  preload( "res://Scenes/Obstacles/SmallRock.tscn" ),
	"Mine"       :  preload( "res://Scenes/Obstacles/Mine.tscn" ),
	"checkpoint" :  preload( "res://Scenes/Checkpoint.tscn" ),
	"Alien1"     :  preload( "res://Scenes/Enemies/Alien1.tscn" ),
	"Alien2"     :  preload( "res://Scenes/Enemies/Alien2.tscn" ),
	"Bomber"     :  preload( "res://Scenes/Enemies/Bomber.tscn" ),
	"PUmissle"   :  preload( "res://Scenes/ProjectTiles/Missle.tscn" ),
	"PFmissle"   :  preload( "res://Scenes/ProjectTiles/Missle_forward.tscn" ),
	"Bomb"       :  preload( "res://Scenes/ProjectTiles/Bomb.tscn" ),
	"Emissle"    :  preload( "res://Scenes/ProjectTiles/Enemy_missle.tscn" )
}

func _ready():
	load_level_structure( "LevelStructure1", 1 )
	load_level_structure( "LevelStructure2", 2 )
	load_level_structure( "LevelStructure3", 3 )
	load_level_structure( "LevelStructure4", 4 )
	load_level_structure( "LevelStructure5", 5 )
	load_level_structure( "LevelStructure6", 6 )

func switch_to_next_segment():
	if sqgment_id < 6 : sqgment_id += 1
	parse_level_list() 

func register_player( node ):
	player = node
	assert( player != null )

func parse_level_list():
	for level in level_jsons[sqgment_id]["level_structure"].keys():
		if level == level_jsons[sqgment_id]["start_segment"]: continue
		level_list.append(level)

func load_level_structure( file_name, segment_index ):
	var file = File.new()
	file.open("res://Resouces/" + file_name + ".json", file.READ)
	level_jsons[segment_index] = parse_json(file.get_as_text())
	file.close()
	assert( level_json != null )

func is_level_fixed():
	return level_jsons[sqgment_id]["fixed_segment"]

func is_randomized():
	return level_jsons[sqgment_id]["random_order"]

func get_start_id():
	return level_jsons[sqgment_id]["start_segment"]

func get_level_segment( level_id ):
	return level_jsons[sqgment_id]["level_structure"][level_id].duplicate(true)

func get_instance( object_name ):
	return objects[object_name].instance()

func get_bezier_interpolate_point( triple_points, t ):
	var invert_t = 1.0-t
	var on_AB = triple_points["a"]*invert_t + triple_points["b"]*t
	var on_BC = triple_points["b"]*invert_t + triple_points["c"]*t
	return  on_AB * invert_t + on_BC*t
