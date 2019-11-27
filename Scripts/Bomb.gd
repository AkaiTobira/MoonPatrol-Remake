extends KinematicBody2D

var direction     = Vector2(0,1)
var SPEED         = 0
var bomber        = null
var triple_points = {}
var max_distance  = 1
var left_distance = 1

func calculate_path( mother_ship ): 
	bomber   = mother_ship
	position = mother_ship.position
	triple_points = { 
		"a" : Vector2(0,0), 
		"b" : Vector2(min( Common.player.position.x - 250 + randi()%200, 1150 ),
		              Common.player.position.y - position.y),
		"c" : 2 * ( Vector2( 0, Common.player.position.y - position.y) ), 
		"relative" : Vector2(0,0) 
	} 
	var farest_point = Common.get_bezier_interpolate_point( triple_points, 0.5 )
	max_distance = (farest_point - triple_points["a"]).length() + (triple_points["c"] - farest_point).length()
	left_distance = max_distance

func update_direction(delta):
	left_distance  = max( left_distance - ( SPEED * delta), 0 )
	var t          = left_distance/max_distance
	var next_point = Common.get_bezier_interpolate_point( triple_points, 1.0-t )
	var velocity_t = (next_point - triple_points["relative"]).normalized()
	triple_points["relative"] += velocity_t*delta * SPEED
	direction  = velocity_t.normalized()

func _physics_process(delta):
	SPEED = min ( SPEED + 250*delta, 500 )
	update_direction(delta)
	var output = move_and_collide( direction * SPEED * delta )
	process_collisions(output)

func process_collisions( object ):
	if object == null : return
	if object.collider.is_in_group("obstacles"): return
	if object.collider.is_in_group("enemy_missle"): return
	if object.collider.is_in_group("missle"): get_parent().points += 100
	if object.collider.is_in_group("player"): 
		on_delete()
		return
	spawn_hole()

func spawn_hole():
	var hole = Common.get_instance("Hole")
	hole.position = position
	hole.position.y = get_parent().get_node("Spawners/Hole_Spawner").position.y
	hole.fixed_y_pos = get_parent().get_node("Spawners/Hole_Spawner").position.y
	get_parent().call_deferred( "add_child", hole )
	on_delete()

func on_delete():
	if is_instance_valid(bomber) or bomber.get("bomb"): 
		bomber.bomb = null
		SquatController.switch_sqaut_special_active( bomber.squat_id, false )
	call_deferred("queue_free")