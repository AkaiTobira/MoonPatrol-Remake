extends KinematicBody2D

export var SPEED = 130

var speed_multipler  = 1
var fixed_y_pos      = 0
var points_jump_over = 50
var points_destroy   = 100
var add_points       = true
var pause            = false

func adapt_speed( speed ):
	SPEED = speed

func grant_points():
	if !Utilities.player: return 
	if Utilities.player.position.x > position.x:
		get_parent().points += points_jump_over
		add_points = false

# warning-ignore:unused_argument
func _physics_process(delta):
	if Flow.world_is_paused: return
# warning-ignore:return_value_discarded
	move_and_slide( Vector2(-1, 0 ) * SPEED  * speed_multipler )
	position.y = fixed_y_pos

	if add_points : grant_points()
	if position.x < -100 : call_deferred("queue_free")

func _on_Area2D_body_entered(body):
	if body.is_in_group("missle"):
		get_parent().points += points_destroy
		body.on_delete()
		$CollisionPolygon2D.call_deferred("queue_free")
		$Area2D.call_deferred("queue_free")

func _on_Area2D2_body_entered(body):
	if body.is_in_group("missle"):
		get_parent().points += points_destroy
		body.on_delete()
		call_deferred("queue_free")
