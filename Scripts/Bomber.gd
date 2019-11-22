extends KinematicBody2D

# warning-ignore:unused_class_variable
onready var player = get_node("/root/Root/Player")
onready var operative_space = { "LT" : Vector2(max( player.move_borders.x - 100, 450 ), 300 ),
                                "RD" : Vector2(player.move_borders.y + 300, 450 ) }

var direction  = Vector2(1, 0)
var move_speed = 250
var squat_id   = -1
var POINTS_FOR_SQUAT_DESTROY = 500

var point_in_space_over_player = Vector2(0, 0)

var move_free      = true
var current_triple = {}
var max_distance   = 1
var left_distance  = 1

func _ready():
	point_in_space_over_player = get_start_point()
	direction                  = (point_in_space_over_player - position).normalized()

func get_cubic_triple():
	var INTERPOLATION_SPACING_V = 80
	var INTERPOLATION_SPACING_H = 80
	var g1 = Vector2(0, 0)
	var g3 = Vector2(0, INTERPOLATION_SPACING_V)   * sign(direction.y) * -1
	var g2 = Vector2(0, INTERPOLATION_SPACING_V/2) * sign(direction.y) * -1 + sign(direction.x) * Vector2(INTERPOLATION_SPACING_H, 0)

	return { "a" : g1, "b" : g2, "c" : g3, "relative": Vector2(0,0) }

func get_bezier_interpolate_point( triple_points, t ):
	var invert_t = 1.0-t
	var on_AB = triple_points["a"]*invert_t + triple_points["b"]*t
	var on_BC = triple_points["b"]*invert_t + triple_points["c"]*t
	return  on_AB * invert_t + on_BC*t

func get_start_point():
	return Vector2( randi() % int( operative_space["RD"].x - operative_space["LT"].x ) + int(operative_space["LT"].x),
	                randi() % int( operative_space["RD"].y - operative_space["LT"].y ) + int(operative_space["LT"].y) )

func get_point_in_space():
	var rt       = position
	var attempts = 0
	while (rt - position).length_squared() < 40000:
		if attempts > 10 : return get_start_point()
		var lenght = randi()%300 + 200
		var dir    = position + (Vector2(1,0) * sign(direction.x ) * lenght)
		rt = dir.rotated( deg2rad( randi()%90 * -1 if randi() %2 == 0 else 1 ) )
		rt.x = max( min( rt.x, operative_space["RD"].x ), operative_space["LT"].x )
		rt.y = randi() % int( operative_space["RD"].y - operative_space["LT"].y ) + int(operative_space["LT"].y)
		attempts += 1
	return rt

func prepare_dodge():
	current_triple = get_cubic_triple()
	var p2 = get_bezier_interpolate_point( current_triple, 0.3 )
	max_distance = (p2 - current_triple["a"]).length() + (current_triple["c"] - p2).length()
	left_distance = max_distance
	move_free = false

func process_linear_move(delta):
	var distance_v = (point_in_space_over_player - position)
	direction      = distance_v.normalized()

	var velocity = direction * move_speed
	var distance = distance_v.length()
	if (velocity * delta).length() > distance :
		velocity = direction * distance
		prepare_dodge()
# warning-ignore:return_value_discarded
	move_and_slide( velocity )

func calculate_dodge_velocity(delta):
	left_distance  = max( left_distance - ( move_speed * delta), 0 )
	var t          = left_distance/max_distance
	var next_point = get_bezier_interpolate_point( current_triple, 1.0-t )
	return  (next_point - current_triple["relative"]).normalized() * move_speed


func process_dodge(delta):
	var velocity_multipler = 1.0
	if left_distance < move_speed*delta :
		velocity_multipler         = left_distance / move_speed * delta
		move_free                  = true
		point_in_space_over_player = get_point_in_space()
	var velocity_t = calculate_dodge_velocity(delta)
# warning-ignore:return_value_discarded
	move_and_slide( velocity_t* velocity_multipler )
	current_triple["relative"] += velocity_t* velocity_multipler*delta
	direction  = velocity_t.normalized()

var timer        = 0
var time_of_life = 12

var dead = false
func select_dead_point():
	if dead : return
	point_in_space_over_player = Vector2( -100 if randi() % 2 == 0 else 2000, position.y )
	move_free = true
	dead      = true

func process_dead():
	if timer < time_of_life: return
	select_dead_point()
	if point_in_space_over_player.distance_to( position ) < 90: on_dead()

func on_dead():
	call_deferred( "queue_free" )
	get_parent().active_squats[squat_id] -= 1

func on_destroy():
	call_deferred( "queue_free" )
	get_parent().active_squats[squat_id] -= 1
	if get_parent().active_squats[squat_id] == 0:
		get_parent().points += POINTS_FOR_SQUAT_DESTROY
		#TODO add text levitating in place of destroyed enemy
		print( squat_id, " Squad is dead " )
	get_parent().points += 100

func _physics_process(delta):
	timer += delta
	process_dead()
	if randi() % 320 == 0 : spawn_missle()
	if move_free: process_linear_move(delta)
	else: process_dodge(delta)

func spawn_missle():
	if position.x > player.position.x + 200: return
	if position.x < player.position.x - 200: return

	var missle_instance = preload("res://Scenes/Enemy_missle.tscn").instance()
	missle_instance.position = position - ( direction.x * 70 ) * Vector2(1,0)

	var missle_target = player.position
	if randi()%2 == 0:
		missle_target.x -= (250 - randi()% 250)
		get_parent().get_node("Sprite").position = missle_target
	else:
		missle_target.x += (250 - randi()% 250)
		get_parent().get_node("Sprite2").position = missle_target

	print( missle_target )
	missle_instance.direction = ( missle_target - missle_instance.position).normalized()
	get_parent().call_deferred( "add_child", missle_instance )

func _on_Area2D_body_entered(body):
	if body.is_in_group("missle"):
		on_destroy()
		body.on_delete()
