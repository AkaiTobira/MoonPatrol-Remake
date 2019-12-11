extends Node

# warning-ignore:unused_class_variable
var high_score = 0

onready var player

var objects = {
	"Hole"       :  preload( "res://Scenes/Obstacles/Hole.tscn" ),
	"HoleB"      :  preload( "res://Scenes/Obstacles/HugeHole.tscn" ),
	"BHole"      :  preload( "res://Scenes/Obstacles/BombHole.tscn" ),
	"Worm"       :  preload( "res://Scenes/Obstacles/WormHole.tscn" ),
	"RockB"      :  preload( "res://Scenes/Obstacles/Rock.tscn" ),
	"RockS"      :  preload( "res://Scenes/Obstacles/SmallRock.tscn" ),
	"Rock2"      :  preload( "res://Scenes/Obstacles/DoubleRock.tscn" ),
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
	current_active_index = 0
	load_structure("LevelStructure1", 0 )
	load_structure("LevelStructure2", 1 )
	load_structure("LevelStructure3", 2 )
	load_structure("LevelStructure4", 3 )
	load_structure("LevelStructure5", 4 )
	load_structure("LevelStructure6", 5 )
	current_active_letter = new_json[current_active_index]["start_segment"]

func register_player( node ):
	player = node
	assert( player != null )

func get_instance( object_name ):
	return objects[object_name].instance()

func get_segment_texture(): pass
#	return level_jsons[sqgment_id]["bakcground"]

#unused
func new_top( id, value ):
	 records[id]["top"] = value


######################################################################################

var new_json = {}
var records  = { 
				0 : { "top": 0, "avg":0 },
				2 : { "top": 0, "avg":0 },
				3 : { "top": 0, "avg":0 },
				4 : { "top": 0, "avg":0 },
				5 : { "top": 0, "avg":0 },
				1 : { "top": 0, "avg":0 },
				6 : { "top": 0, "avg":0 }
}

var current_active_index  = -1
var current_active_letter = ""
var max_segments          = 6
var level_structure = {}

func load_structure(file_name, segment_index):
	var file = File.new()
	file.open("res://Resouces/" + file_name + ".json", file.READ)
	new_json[segment_index] = parse_json(file.get_as_text())
	file.close()
	assert( new_json[segment_index] != null )
	generate_level_segment_orded( segment_index )

func generate_level_segment_orded( segment_index ):
	randomize()
	level_structure[segment_index] = {}
	for letter in new_json[segment_index]["level_structure"].keys():
		var temp = new_json[segment_index]["level_structure"][letter]
		level_structure[segment_index][letter] = str(randi()%len(temp.keys())) 

func get_active_spawn_times():
	var selected_variant = level_structure[current_active_index][current_active_letter]
	return new_json[current_active_index]["level_structure"][current_active_letter][selected_variant].duplicate(true)
	
func reached_next_letter( letter ):
	if new_json[current_active_index]["end_segment"] == letter:
		reached_next_segment( current_active_letter )
		Flow.summarize( letter, 
						new_json[current_active_index]["additional_points"],  
						new_json[current_active_index]["avr_time"],
						get_top_record()
						)
		return
	current_active_letter = letter

func get_top_record():
	if not records[current_active_index]["top"]: records[current_active_index]["top"] = new_json[current_active_index]["avr_time"]
	return records[current_active_index]["top"]

func reached_next_segment( backup_letter ):
	if max_segments > current_active_index + 1 : 
		current_active_index += 1
		current_active_letter = new_json[current_active_index]["start_segment"]
	else: current_active_letter = backup_letter
 
func save_top_record( new_time ):
	if records[ current_active_index ]["top"] < new_time :  records[ current_active_index ]["top"] = new_time

##############################################

func get_bezier_interpolate_point( triple_points, t ):
	var invert_t = 1.0-t
	var on_AB = triple_points["a"]*invert_t + triple_points["b"]*t
	var on_BC = triple_points["b"]*invert_t + triple_points["c"]*t
	return  on_AB * invert_t + on_BC*t
