extends KinematicBody2D

onready var player = get_node("/root/Root/Player")
onready var operative_space = { "LT" : Vector2(max( player.move_borders.x - 100, 450 ), 300 ), 
                                "RD" : Vector2(player.move_borders.y + 100, 600 ) }

var direction  = Vector2(1, 0)
var velocity   = Vector2(0, 0)
var move_speed = 300

var point_in_space_over_player = Vector2(0, 0) 

func _ready(): 
	point_in_space_over_player = get_point_in_space()
	direction                  = (point_in_space_over_player - position).normalized()

func get_cubic_triple():
	relative_point = Vector2(0,0)
	var roz = 170
	var g1 = Vector2(0,0)# position = Vector2(0,0)
	get_parent().get_node("Sprite").position = position
	var g3 = Vector2(0, roz) * sign(direction.y) * -1
	get_parent().get_node("Sprite3").position = position + Vector2(0, roz) * sign(direction.y) * -1
	var g2 = Vector2(0, roz/2) * sign(direction.y) * -1 + sign(direction.x) * Vector2( roz, 0 ) 
	get_parent().get_node("Sprite2").position = position + Vector2(0, roz/2) * sign(direction.y) * -1 + sign(direction.x) * Vector2( roz, 0 )
	return { "a" : g1, "b" : g2, "c" : g3 }

func get_bezier_point( triple_points, t ):
	
	var invert_t = 1.0-t
	
	var v = triple_points["a"]*invert_t + triple_points["b"]*t
	var g = triple_points["b"]*invert_t + triple_points["c"]*t
	
	var z = v * invert_t + g*t
	print( "X + ", z, " t=", t , triple_points )
	return  z
	

func get_point_in_space():
	return Vector2( randi() % int( operative_space["RD"].x - operative_space["LT"].x ) + int(operative_space["LT"].x),
	                randi() % int( operative_space["RD"].y - operative_space["LT"].y ) + int(operative_space["LT"].y) )

var move_free      = true
var current_triple = {}
var distance2      = 1000000
var distance3      = 1000000

var relative_point = Vector2(0,0)
func _physics_process(delta):
	
	if move_free: 
		var distance   = (point_in_space_over_player - position).length()
		var velocity_t = (point_in_space_over_player - position).normalized() * move_speed
		if (velocity_t * delta).length() > distance : 
			direction  = velocity_t.normalized()
			velocity_t = velocity_t.normalized() * distance
			point_in_space_over_player = get_point_in_space()
			current_triple = get_cubic_triple()
			
			var p2 = get_bezier_point( current_triple, 0.5 )
		#	print( p2, current_triple, position )
			distance2 = (p2 - current_triple["a"]).length() + (current_triple["c"] - p2).length()
		#	print( distance2 )
			distance3 = distance2 
			
			move_free = false
		move_and_slide( velocity_t )
	else:
		var velocity_multipler = 1.0
		if distance3 < move_speed*delta : 
			velocity_multipler = distance3/move_speed*delta
			move_free = true
			point_in_space_over_player = get_point_in_space()
			get_parent().get_node("Sprite4").position = point_in_space_over_player
		distance3 = max( distance3 - ( move_speed * delta), 0 )
		var t = distance3/distance2
		var p3 = get_bezier_point( current_triple, 1.0-t )
		#print( t, " ", p3, " ", p3 - relative_point, " ", relative_point )
		var velocity_t = (p3 - relative_point).normalized() * move_speed
		relative_point += velocity_t* velocity_multipler*delta
		move_and_slide( velocity_t* velocity_multipler )
		direction  = velocity_t.normalized()		
		#print( get_bezier_point( current_triple, 0.5 ) )
		return 
	
	#print( get_bezier_point( { "a": Vector2(0,0), "b" : Vector2(1,2), "c" : Vector2(2,0) }, 0.5 ) )
	#var distance2 = (point_in_space_over_player - position).length_squared()
	#print( distance )#, " ", distance2 ) 
	#print( get_point_in_space() )