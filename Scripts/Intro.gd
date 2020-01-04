extends Node2D

# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_released("ui_accept"):
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Scenes/Game.tscn")
