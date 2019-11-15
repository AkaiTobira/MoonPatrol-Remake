extends KinematicBody2D

export var SPEED = 100

var speed_multipler = 1
var fixed_y_pos = 0

func set_speed_multipler( player_multipler ):
	speed_multipler = 1 + player_multipler
	
# warning-ignore:unused_argument
func _physics_process(delta):
# warning-ignore:return_value_discarded
	move_and_slide( Vector2(-1, 0 ) * SPEED * speed_multipler )
	position.y = fixed_y_pos
	
	if position.x < -100 : call_deferred("queue_free")

func _on_Area2D_body_entered(body):
	if body.is_in_group("missle"):
		#TODO add points
		body.on_delete()
		call_deferred("queue_free")

