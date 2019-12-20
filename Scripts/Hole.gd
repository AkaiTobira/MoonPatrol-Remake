extends KinematicBody2D

export var SPEED = 130

var points          = 50
var add_points      = true

var speed_multipler = 1
var fixed_y_pos     = 0

func grant_points():
	if !Utilities.player: return 
	if Utilities.player.position.x > position.x:
		get_parent().points += points
		add_points = false

func adapt_speed( speed ):
	SPEED = speed

# warning-ignore:unused_argument
func _physics_process(delta):
	if Flow.world_is_paused: return

	position.x -=  -1 * SPEED * speed_multipler * delta
	position.y  = fixed_y_pos
	
	if add_points : grant_points()
	if position.x < -100 : call_deferred("queue_free")