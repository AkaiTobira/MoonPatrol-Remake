extends KinematicBody2D

export var SPEED = 100

# warning-ignore:unused_argument
func _physics_process(delta):
# warning-ignore:return_value_discarded
	move_and_slide( Vector2(-1, 0 ) * SPEED )

func _on_Area2D_body_entered(body):
	if body.is_in_group("missle"):
		#TODO add points
		body.call_deferred("queue_free")
		call_deferred("queue_free")
