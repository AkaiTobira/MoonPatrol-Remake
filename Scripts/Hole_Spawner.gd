extends Node2D

onready var hole     = load( "res://Scenes/Hole.tscn" )
onready var hugehole = load( "res://Scenes/HugeHole.tscn" )
onready var wormhole = load( "res://Scenes/WormHole.tscn" )

func _ready():
	get_child(0).SPEED      = 0
	get_child(0).add_points = false

func spawn(obstacle):
	var instance = null
	match obstacle:
		"Hole"  : instance = hole.instance()
		"HoleB" : instance = hugehole.instance()
		"Worm"  : instance = wormhole.instance()
	instance.fixed_y_pos = position.y
	instance.position = position
	get_parent().add_child(instance)
