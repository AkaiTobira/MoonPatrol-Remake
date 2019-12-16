extends Node2D

func _ready():
	get_child(0).SPEED          = 0
	get_child(0).set_process(false)
	get_child(0).is_not_reached = false

func spawn( instance, letter ):
#	instance.fixed_y_pos = position.y
#	instance.position    = position

	#$Sprite.offset = position
	
	instance.offset = position
	
	instance.set_letter(letter)
	get_parent().get_parent().add_child(instance)
