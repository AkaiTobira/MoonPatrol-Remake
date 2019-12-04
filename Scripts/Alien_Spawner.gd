extends Node2D


func spawn(instance, squat_id, number_of_enemies):
	instance.squat_id = squat_id
	if number_of_enemies > 2:
		instance.POINTS_FOR_SQUAT_DESTROY = 500
	if number_of_enemies > 3:
		instance.POINTS_FOR_SQUAT_DESTROY = 800
	if number_of_enemies > 4:
		instance.POINTS_FOR_SQUAT_DESTROY = 1000
	instance.position = position
	get_parent().get_parent().add_child(instance)
