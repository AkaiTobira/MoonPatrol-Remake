extends KinematicBody2D

export var SPEED = 130

var speed_multipler = 1
var points          = 50
var fixed_y_pos     = 0
var add_points      = true

func adapt_speed( speed ):
	SPEED = speed

func grant_points():
	if !Utilities.player: return 
	if Utilities.player.position.x > position.x:
		get_parent().points += points
		add_points = false

# warning-ignore:unused_argument
func _physics_process(delta):
# warning-ignore:return_value_discarded
	if Flow.world_is_paused : return 
	move_and_slide( Vector2(-1, 0 ) * SPEED * speed_multipler )
	position.y = fixed_y_pos
	
	if add_points : grant_points()
	if position.x < -100 : call_deferred("queue_free")