extends Node2D

var timer     = 0
var timer_max = 10

onready var hole = load( "res://Scenes/Hole.tscn" )

func _process(delta):
	timer += delta
	if timer > timer_max:
		var instance = hole.instance()
		instance.position = position
		get_parent().add_child(instance)
		timer_max = randi()%12 + 5
		timer = 0
