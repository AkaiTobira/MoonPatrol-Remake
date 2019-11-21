extends Node2D

func _ready():
	get_child(0).SPEED      = 0
	get_child(0).add_points = false

func spawn( instance ):
	instance.fixed_y_pos = position.y
	instance.position = position
	get_parent().get_parent().add_child(instance)
