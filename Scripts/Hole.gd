extends KinematicBody2D

export var SPEED = 100

var fixed_y_pos = 0

# warning-ignore:unused_argument
func _physics_process(delta):
# warning-ignore:return_value_discarded
	move_and_slide( Vector2(-1, 0 ) * SPEED )
	position.y = fixed_y_pos
	
	if position.x < -100 : call_deferred("queue_free")