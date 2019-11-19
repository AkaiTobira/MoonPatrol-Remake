extends Node2D

onready var rock      = load( "res://Scenes/Rock.tscn" )
onready var smallRock = load( "res://Scenes/SmallRock.tscn" )

func _ready():
	get_child(0).SPEED      = 0
	get_child(0).add_points = false

func spawn( obstacle ):
	var instance = null
	match obstacle:
		"RockB" : instance = rock.instance()
		"RockS" : instance = smallRock.instance()
	instance.fixed_y_pos = position.y
	instance.position = position
	get_parent().add_child(instance)
