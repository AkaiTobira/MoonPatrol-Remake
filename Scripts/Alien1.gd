extends KinematicBody2D

# warning-ignore:unused_class_variable
onready var player = get_node("/root/Root/Player")
onready var operative_space = { "LT" : Vector2(max( player.move_borders.x - 100, 450 ), 300 ), 
                                "RD" : Vector2(player.move_borders.y + 200, 500 ) }

var direction  = Vector2(1, 0)
var move_speed = 300

var point_in_space_over_player = Vector2(0, 0) 

func _ready(): 
	point_in_space_over_player = get_point_in_space()
	direction                  = (point_in_space_over_player - position).normalized()

func get_cubic_triple():
	relative_point = Vector2(0,0)
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

func get_point_in_space():
	var rt = position
	while (rt - position).length_squared() < 40000: 
		var lenght = randi()%200 + 200
		var dir    = position + (Vector2(1,0) * sign(direction.x ) * lenght)
		
		
		rt = dir.rotated( deg2rad( randi()%90 * -1 if randi() %2 == 0 else 1 ) )  
		
		print( rt, " ", operative_space )
		
	#	rt.y = min( max( rt.y, operative_space["LT"].y ), operative_space["RD"].y )
		rt.x = max( min( rt.x, operative_space["RD"].x ), operative_space["LT"].x )
		
		rt.y = randi() % int( operative_space["RD"].y - operative_space["LT"].y ) + int(operative_space["LT"].y)  
		
		print( "Selected ", rt )
	return rt
	print( rt )
	
	return Vector2( randi() % int( operative_space["RD"].x - operative_space["LT"].x ) + int(operative_space["LT"].x),
	                randi() % int( operative_space["RD"].y - operative_space["LT"].y ) + int(operative_space["LT"].y) )

var move_free      = true
var current_triple = {}
var max_distance      = 1000000
var left_distance      = 1000000

var relative_point = Vector2(0,0)

func process_linear_move(delta):
	var distance_v = (point_in_space_over_player - position)
	direction      = distance_v.normalized()
	
	var velocity_t = direction * move_speed
	var distance   = distance_v.length()
	if (velocity_t * delta).length() > distance : 
		velocity_t     = direction * distance
		current_triple = get_cubic_triple()
		#THIS PART IS STILL TO REFACTOR ... and everything below
		var p2 = get_bezier_interpolate_point( current_triple, 0.3 )
		max_distance = (p2 - current_triple["a"]).length() + (current_triple["c"] - p2).length()
		left_distance = max_distance 
		move_free = false
# warning-ignore:return_value_discarded
	move_and_slide( velocity_t )

func process_dodge(delta):
	var velocity_multipler = 1.0
	if left_distance < move_speed*delta : 
		velocity_multipler         = left_distance / move_speed * delta
		move_free                  = true
		point_in_space_over_player = get_point_in_space()
	#	get_parent().get_node("Sprite4").position = point_in_space_over_player
	left_distance = max( left_distance - ( move_speed * delta), 0 )
	var t = left_distance/max_distance
	var p3 = get_bezier_interpolate_point( current_triple, 1.0-t )
	var velocity_t = (p3 - current_triple["relative"]).normalized() * move_speed
	current_triple["relative"] += velocity_t* velocity_multipler*delta
# warning-ignore:return_value_discarded
	move_and_slide( velocity_t* velocity_multipler )
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
	if point_in_space_over_player.distance_to( position ) < 10: call_deferred( "queue_free" )
	

func _physics_process(delta):
	timer += delta
	process_dead()
	
	if move_free: process_linear_move(delta)
	else: process_dodge(delta)
