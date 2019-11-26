extends KinematicBody2D

export var SPEED = 130

var speed_multipler = 1
var points          = 50
var fixed_y_pos     = 0
var add_points      = true

func set_speed_multipler( player_multipler ):
	speed_multipler = 1 + player_multipler

func grant_points():
	if !Common.player: return 
	if Common.player.position.x > position.x:
		get_parent().points += points
		add_points = false

func _physics_process(delta):
# warning-ignore:return_value_discarded
	move_and_slide( Vector2(-1, 0 ) * SPEED * speed_multipler )
	position.y = fixed_y_pos
	
	if add_points : grant_points()
	if position.x < -100 : call_deferred("queue_free")