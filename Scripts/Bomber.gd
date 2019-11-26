extends "res://Scripts/Alien_Base.gd"

func _ready():
	._ready()
	operative_space = { "LT" : Vector2(max( player.move_borders.x - 100, 550 ), 300 ),
                        "RD" : Vector2(player.move_borders.y + 800, 400 ) }
	MAX_PRECISION          = 500
	DISTANCE_FOR_NEW_POINT = 400
	move_speed             = 350
	PRECISION_UPDATE       = 0
	SHOOT_PROBABILITY      = 1
	KAMIKAZE_ENABLED       = false
	LIFE_TIME              = 12
	
func _physics_process(delta):
	update_times(delta)
	process_dead()
	process_bombing(delta)
#	process_shooting()
	process_move(delta)

var bomb = null
var bomb_triple_points = {}
var bomb_max_distance  = 1
var bomb_left_distance = 1
func process_bombing(delta):
	if bomb == null :
		if not get_parent().active_squats[squat_id][1]:
			if randi()%SHOOT_PROBABILITY == 0 :
				get_parent().active_squats[squat_id][1] = true
				bomb = preload( "res://Scenes/ProjectTiles/Bomb.tscn" ).instance()
				bomb.position = position
				bomb.bomber = self
				var bomb_target = player.position +Vector2(300  + randi()%300, 0 )
				get_parent().get_node( "Sprite2" ).position = bomb_target
				bomb_triple_points = { "a" : position, "b" : bomb_target, "c" : position + 2 * ( Vector2( 0, bomb_target.y - position.y) ), "relative" : Vector2(0,0) } 
				var farest_point = get_bezier_interpolate_point( bomb_triple_points, 0.5 )
				bomb_max_distance = (farest_point - bomb_triple_points["a"]).length() + (bomb_triple_points["c"] - farest_point).length()
				bomb_left_distance = bomb_max_distance
				get_parent().call_deferred( "add_child", bomb )
	else:
		bomb_left_distance  = max( bomb_left_distance - ( bomb.SPEED * delta), 0 )
		var t          = bomb_left_distance/bomb_max_distance
		var next_point = get_bezier_interpolate_point( bomb_triple_points, 1.0-t )
		var velocity_t = (next_point - bomb_triple_points["relative"]).normalized() * bomb.SPEED
		bomb_triple_points["relative"] += velocity_t*delta
		bomb.velocity   = velocity_t
		bomb.direction  = velocity_t.normalized()
	pass
	
func on_destroy():
	if bomb: bomb.bomber = null
	.on_destroy()
	print( "Destroyed" )
	
func on_dead():
	if bomb: bomb.bomber = null
	.on_dead()
	print( "RunAway" )