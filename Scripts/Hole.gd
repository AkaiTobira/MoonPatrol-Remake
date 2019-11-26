extends KinematicBody2D

export var SPEED = 130

var points          = 50
var add_points      = true
var pause           = false

var speed_multipler = 1
var fixed_y_pos     = 0

func grant_points():
	if !Common.player: return 
	if Common.player.position.x > position.x:
		get_parent().points += points
		add_points = false

func play(): pause = false
func stop(): pause = true

func set_speed_multipler( player_multipler ):
	speed_multipler = 1 + player_multipler

func _physics_process(delta):
	if pause: return 
# warning-ignore:return_value_discarded
	move_and_slide( Vector2(-1, 0 ) * SPEED * speed_multipler * delta )
	position.y = fixed_y_pos
	
	if add_points : grant_points()
	if position.x < -100 : call_deferred("queue_free")