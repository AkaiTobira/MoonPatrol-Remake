extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_released("ui_accept"):
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Scenes/Game.tscn")
