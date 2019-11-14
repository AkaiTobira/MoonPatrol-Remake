extends KinematicBody2D

export var SPEED = 100

# warning-ignore:unused_argument
func _physics_process(delta):
# warning-ignore:return_value_discarded
	move_and_slide( Vector2(-1, 0 ) * SPEED )