extends KinematicBody2D

export var SPEED = 130

var points          = 50
var add_points      = true

var speed_multipler = 1
var fixed_y_pos     = 0

var squat_id        = -1 

func adapt_speed( speed ):
	SPEED = speed

func grant_points():
	if !Utilities.player: return 
	if Utilities.player.position.x > position.x:
		SquatController.bomb_exploded( squat_id )
		get_parent().points += points
		add_points = false

func set_speed_multipler( player_multipler ):
	speed_multipler = 1 + player_multipler

func on_delete():
	pass

# warning-ignore:unused_argument
func _physics_process(delta):
	if Flow.world_is_paused: return 
# warning-ignore:return_value_discarded
	move_and_slide( Vector2(-1, 0 ) * SPEED * speed_multipler )
	position.y = fixed_y_pos
	
	if add_points : grant_points()
	if position.x < -100 : call_deferred("queue_free")