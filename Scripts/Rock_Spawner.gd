extends Node2D

onready var rock = load( "res://Scenes/Rock.tscn" )

func _ready():
	get_child(0).SPEED = 0

func spawn():
	var instance = rock.instance() 
	instance.fixed_y_pos = position.y
	instance.position = position
	get_parent().add_child(instance)
