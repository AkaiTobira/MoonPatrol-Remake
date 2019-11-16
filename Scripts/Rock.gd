extends KinematicBody2D

export var SPEED = 100

var speed_multipler  = 1
var fixed_y_pos      = 0
var points_jump_over = 80
var points_destroy   = 100
var add_points       = true

onready var player = get_node("/root/Root/Player")

func set_speed_multipler( player_multipler ):
	speed_multipler = 1 + player_multipler

func grant_points():
	if !player: return 
	if player.position.x > position.x:
		get_parent().points += points_jump_over
		add_points = false
	
# warning-ignore:unused_argument
func _physics_process(delta):
# warning-ignore:return_value_discarded
	move_and_slide( Vector2(-1, 0 ) * SPEED * speed_multipler )
	position.y = fixed_y_pos

	if add_points : grant_points()
	if position.x < -100 : call_deferred("queue_free")

func _on_Area2D_body_entered(body):
	if body.is_in_group("missle"):
		get_parent().points += points_destroy
		body.on_delete()
		call_deferred("queue_free")

