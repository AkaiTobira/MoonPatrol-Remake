extends Area2D

var direction     = Vector2(0,1)
var SPEED         = 250
var triple_points = {}
var max_distance  = 1
var left_distance = 1
var squat_id      = 0
var road_speed    = 0

func calculate_path( mother_ship ): 
	position = mother_ship.position + Vector2( 30, 0 )
	squat_id = mother_ship.squat_id
	triple_points = { 
		"a" : Vector2(0,0), 
		"b" : Vector2(min( Utilities.player.position.x + 250 + randi()%300, 625 ),
		                   Utilities.player.position.y - position.y),
		"c" : 2 * ( Vector2( 0, Utilities.player.position.y - position.y) ), 
		"relative" : Vector2(0,0) 
	} 
	var farest_point = Utilities.get_bezier_interpolate_point( triple_points, 0.5 )
	max_distance = (farest_point - triple_points["a"]).length() + (triple_points["c"] - farest_point).length()
	left_distance = max_distance

func adapt_speed( speed ): 
	road_speed = speed

func update_direction(delta):
	var a_distance_x = abs(triple_points["b"].x - triple_points["a"].x)
	var t_2 = float(triple_points["b"].x - triple_points["relative"].x ) / a_distance_x
	direction  = Vector2( t_2, 1-t_2 ).normalized()
	triple_points["relative"] += direction*delta * SPEED

func _physics_process(delta):
	update_direction(delta)
	position += direction * SPEED * delta
#	var output = move_and_collide( direction * SPEED * delta )
#	process_collisions(output, delta)
	SPEED = min ( SPEED + 250*delta, 500 )
	
	if $AnimationPlayer.current_animation == "Dead":
		SPEED = 0
		position.x -= road_speed * delta

func play_animation_if_not_player( anim_name ):
	if $AnimationPlayer.current_animation == anim_name : return
	$AnimationPlayer.play(anim_name)

func spawn_hole():
	var hole = Utilities.get_instance("BHole")
	hole.squat_id = squat_id
	hole.position = position
	hole.position.y  = get_parent().get_node("Spawners/Hole_Spawner").position.y
	hole.fixed_y_pos = get_parent().get_node("Spawners/Hole_Spawner").position.y
	Flow.adapt_height( hole )
	get_parent().call_deferred( "add_child", hole )

func on_delete():
	call_deferred("queue_free")

func _on_Bomb_body_entered(body):
	if body == null : return
	
	var ignorable = body.is_in_group("alien") or body.is_in_group("missle") 
	
	if body.is_in_group("obstalces") and not ignorable:
		SquatController.bomb_exploded( squat_id )
		on_delete()
	
	if body.is_in_group("missle"): 
		get_parent().points += 100
		SquatController.bomb_exploded( squat_id )
		on_delete()
	if body.is_in_group("player"): on_delete()
	if body.is_in_group("floor"):  play_animation_if_not_player("Dead")
