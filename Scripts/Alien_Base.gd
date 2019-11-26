extends KinematicBody2D

onready var previous_player_position = Vector2(0,0)
var operative_space = { "LT" : Vector2(450, 300),
                        "RD" : Vector2(750, 450) }

#kamikaze variables
var KAMIKAZE_PROBABILITY = 5
var KAMIKAZE_ENABLED     = true

#shooting variables
var current_precision = 250
var MAX_PRECISION     = 250
var PRECISION_UPDATE  = 30
var SHOOT_PROBABILITY = 320
var precision_update_timer        = 0
var max_precision_update_timer    = 1

#move variables
var move_speed           = 250
var direction            = Vector2(1, 0)
var DISTANCE_FOR_NEW_POINT = 200
var target_move_point    = Vector2(0, 0)
var avoid                = false
var current_triple       = {}
var full_avoid_distance  = 1
var left_avoid_distance  = 1

# Squat info
var squat_id   = -1
var POINTS_FOR_SQUAT_DESTROY = 0

#Life duration
var life_timer = 0
var LIFE_TIME  = 12
var is_dead    = false

func _ready():
	target_move_point = get_start_point()
	direction         = (target_move_point - position).normalized()

func get_start_point():
	return Vector2( randi() % int( operative_space["RD"].x - operative_space["LT"].x ) + int(operative_space["LT"].x),
	                randi() % int( operative_space["RD"].y - operative_space["LT"].y ) + int(operative_space["LT"].y) )

func update_times(delta):
	life_timer             += delta
	precision_update_timer += delta

func process_dead():
	if life_timer < LIFE_TIME: return
	select_life_end_point()
	if target_move_point.distance_to( position ) < 3: on_dead()

func select_life_end_point():
	if is_dead : return
	target_move_point = Vector2( -100 if randi() % 2 == 0 else 2000, position.y )
	enable_kamikaze_atack()
	avoid   = false
	is_dead = true

func enable_kamikaze_atack():
	if not KAMIKAZE_ENABLED: return
	if not get_parent().get_node("Squat_controller").active_squats[squat_id][1]:
		if randi()%KAMIKAZE_PROBABILITY == 0: 
			get_parent().get_node("Squat_controller").active_squats[squat_id][1] = true
			target_move_point = Common.player.position + Vector2( randi()%20 * -1 if randi()%2 == 0 else 1, 10 ) 

func on_dead():
	call_deferred( "queue_free" )
	get_parent().get_node("Squat_controller").active_squats[squat_id][0] -= 1

func process_shooting():
	update_precision()
	if not randi() % SHOOT_PROBABILITY == 0  : return
	if is_far_from_player(): return 
	create_missle()

func is_far_from_player():
	if position.x > Common.player.position.x + 200: return true
	if position.x < Common.player.position.x - 200: return true
	return false

func create_missle():
	var missle_instance = Common.get_instance("Emissle")
	missle_instance.position  = position - ( direction.x * 70 ) * Vector2(1,0)
	missle_instance.direction = (get_missle_target() - missle_instance.position).normalized()
	get_parent().call_deferred( "add_child", missle_instance )

func get_missle_target():
	var missle_target = Common.player.position
	var disruption    = (current_precision - randi()% int(current_precision/2))
	missle_target.x   += ( disruption if randi()%2 else -disruption )
	return missle_target 

func update_precision():
	if precision_update_timer < max_precision_update_timer: return
	precision_update_timer = 0 
	if is_player_moved(): current_precision = max( 2, current_precision - PRECISION_UPDATE )
	else: current_precision = min( MAX_PRECISION, current_precision + PRECISION_UPDATE )
	previous_player_position = Common.player.position 

func is_player_moved():
	var is_in_limit_from_left  = Common.player.position.x > (previous_player_position.x - 10)
	var is_in_limit_from_right = Common.player.position.x < (previous_player_position.x + 10)
	return is_in_limit_from_left and is_in_limit_from_right

func process_move(delta):
	if not avoid: move_to_target_pos(delta)
	else: move_avoiding(delta)

func move_to_target_pos(delta):
	var distance_v = (target_move_point - position)
	direction      = distance_v.normalized()

	var velocity = direction * move_speed
	var distance = distance_v.length()
	if (velocity * delta).length() > distance :
		velocity = direction * distance
		change_to_avoid()
# warning-ignore:return_value_discarded
	move_and_slide( velocity )

func change_to_avoid():
	current_triple   = get_checkpoints()
	var farest_point = Common.get_bezier_interpolate_point( current_triple, 0.5 )
	full_avoid_distance = (farest_point - current_triple["a"]).length() + (current_triple["c"] - farest_point).length()
	left_avoid_distance = full_avoid_distance
	avoid = true

func get_checkpoints():
	var INTERPOLATION_SPACING_V = 80
	var INTERPOLATION_SPACING_H = 200
	var g1 = Vector2(0, 0)
	var g3 = Vector2(0, INTERPOLATION_SPACING_V)   * sign(direction.y) * -1
	var g2 = Vector2(0, INTERPOLATION_SPACING_V/2) * sign(direction.y) * -1 + sign(direction.x) * Vector2(INTERPOLATION_SPACING_H, 0)
	return { "a" : g1, "b" : g2, "c" : g3, "relative": Vector2(0,0) }

func move_avoiding(delta):
	var velocity_multipler = 1.0
	if left_avoid_distance < move_speed*delta :
		velocity_multipler = left_avoid_distance / move_speed * delta
		change_to_simple_move()
	var velocity_t = calculate_avoid_velocity(delta)
# warning-ignore:return_value_discarded
	move_and_slide( velocity_t* velocity_multipler )
	current_triple["relative"] += velocity_t* velocity_multipler*delta
	direction  = velocity_t.normalized()

func change_to_simple_move():
	avoid              = false
	target_move_point = get_next_target_point()

func get_next_target_point():
	var new_position = position
	var attempts = 0
	while (new_position - position).length_squared() < 40000:
		if attempts > 10 : return get_start_point()
		new_position = generate_new_position_point(new_position)
		attempts += 1
	return new_position

func generate_new_position_point(new_position):
	var new_positon_y = new_position.y
	var lenght = randi()%300 + DISTANCE_FOR_NEW_POINT
	var dir    = position + (Vector2(1,0) * sign(direction.x ) * lenght)
	new_position = dir.rotated( deg2rad( randi()%90 * -1 if randi() %2 == 0 else 1 ) )
	new_position = fit_in_operative_space(Vector2( new_position.x, new_positon_y))
	return new_position

func fit_in_operative_space(position):
	position.x = max( min( position.x, operative_space["RD"].x ), operative_space["LT"].x )
	#y is random
	position.y = randi() % int( operative_space["RD"].y - operative_space["LT"].y ) + int(operative_space["LT"].y)
	return position

func calculate_avoid_velocity(delta):
	left_avoid_distance  = max( left_avoid_distance - ( move_speed * delta), 0 )
	var t          = left_avoid_distance/full_avoid_distance
	var next_point = Common.get_bezier_interpolate_point( current_triple, 1.0-t )
	return (next_point - current_triple["relative"]).normalized() * move_speed

func on_destroy():
	call_deferred( "queue_free" )
	var node = get_parent().get_node("Squat_controller")
	node.active_squats[squat_id][0] -= 1
	if node.active_squats[squat_id][0] == 0:
		get_parent().points += POINTS_FOR_SQUAT_DESTROY
		#TODO add text levitating in place of destroyed enemy
		print( squat_id, " Squad is is_dead " )
	get_parent().points += 100

func _on_Area2D_body_entered(body):
	if body.is_in_group("missle"):
		on_destroy()
		body.on_delete()
	elif body.is_in_group("player"):
		on_destroy()
		body.on_dead()

