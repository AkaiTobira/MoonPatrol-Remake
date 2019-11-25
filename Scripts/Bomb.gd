extends KinematicBody2D

var direction = Vector2(0,1)
var SPEED     = 0
var bomber    = null
var velocity  = Vector2(0,0)

func _physics_process(delta):
	SPEED = min ( SPEED + 250*delta, 500 )
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
	var hole = preload( "res://Scenes/Obstacles/Hole.tscn" ).instance()
	hole.position = position
	hole.position.y = get_parent().get_node("Spawners/Hole_Spawner").position.y
	hole.fixed_y_pos = get_parent().get_node("Spawners/Hole_Spawner").position.y
	get_parent().call_deferred( "add_child", hole )
	on_delete()

func on_delete():
	if is_instance_valid(bomber) : 
		bomber.bomb = null
		get_parent().active_squats[bomber.squat_id][1] = false
	call_deferred("queue_free")