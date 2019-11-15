extends Node2D

onready var checkpoint = load( "res://Scenes/Checkpoint.tscn" )

func _ready():
	get_child(0).SPEED = 0

func spawn( letter ):
	var instance         = checkpoint.instance() 
	instance.fixed_y_pos = position.y
	instance.position    = position
	instance.set_letter(letter)
	get_parent().add_child(instance)
