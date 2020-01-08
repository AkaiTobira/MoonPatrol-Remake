extends Node

var player       = null
# warning-ignore:unused_class_variable
var PIXOMETR     = 0
# warning-ignore:unused_class_variable
var player_speed = 5

var objects = {
	"Hole"       :  preload( "res://Scenes/Obstacles/Hole.tscn" ),
	"HoleB"      :  preload( "res://Scenes/Obstacles/HugeHole.tscn" ),
	"BHole"      :  preload( "res://Scenes/Obstacles/BombHole.tscn" ),
	"Worm"       :  preload( "res://Scenes/Obstacles/WormHole.tscn" ),
	"RockB"      :  preload( "res://Scenes/Obstacles/Rock.tscn" ),
	"RockS"      :  preload( "res://Scenes/Obstacles/SmallRock.tscn" ),
	"Rock2"      :  preload( "res://Scenes/Obstacles/DoubleRock.tscn" ),
	"Round"      :  preload( "res://Scenes/Obstacles/RoundBulder.tscn" ),
	"RoundS"     :  preload( "res://Scenes/Obstacles/SmallRoundBulder.tscn" ),
	"Mine"       :  preload( "res://Scenes/Obstacles/Mine.tscn" ),
	"checkpoint" :  preload( "res://Scenes/Checkpoint.tscn" ),
	"Alien1"     :  preload( "res://Scenes/Enemies/Alien1.tscn" ),
	"Alien2"     :  preload( "res://Scenes/Enemies/Alien2.tscn" ),
	"Bomber"     :  preload( "res://Scenes/Enemies/Bomber.tscn" ),
	"PUmissle"   :  preload( "res://Scenes/ProjectTiles/Missle.tscn" ),
	"PFmissle"   :  preload( "res://Scenes/ProjectTiles/Missle_forward.tscn" ),
	"Bomb"       :  preload( "res://Scenes/ProjectTiles/Bomb.tscn" ),
	"IRoad1"     :  preload( "res://Scenes/Inclined_Road.tscn" ),
	"IRoad2"     :  preload( "res://Scenes/Inclined_Road.tscn" ),
	"Emissle"    :  preload( "res://Scenes/ProjectTiles/Enemy_missle.tscn" )
}

var background = {
	"1" : {
		"road"  : preload("res://Textures/Placeholders_new/road_1.png" ),
		"back1" : preload("res://Textures/Placeholders_new/hill_1.png" ),
		"back2" : preload("res://Textures/Placeholders_new/hill_3.png" ),
		"inclined_name" : "IRoad1"
		},
	"2" : {
		"road"  : preload("res://Textures/Placeholders_new/road_1.png" ),
		"back1" : preload("res://Textures/Placeholders_new/hill_2.png" ),
		"back2" : preload("res://Textures/Placeholders_new/hill_4.png" ),
		"inclined_name" : "IRoad2"
		}
}

func get_backgrounds( t_name ):
	if t_name == "dessert" : return background["1"]
	if t_name == "hills"   : return background["2"]

func get_bezier_interpolate_point( triple_points, t ):
	var invert_t = 1.0-t
	var on_AB = triple_points["a"]*invert_t + triple_points["b"]*t
	var on_BC = triple_points["b"]*invert_t + triple_points["c"]*t
	return  on_AB * invert_t + on_BC*t
	
func register_player( node ):
	player = node
	assert( player != null )

func get_instance( object_name ):
	return objects[object_name].instance()

func get_segment_texture(): pass
#	return level_jsons[sqgment_id]["bakcground"]
