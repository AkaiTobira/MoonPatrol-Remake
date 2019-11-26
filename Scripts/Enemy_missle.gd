extends KinematicBody2D

var direction = Vector2(0,1)
var SPEED     = 0

func _physics_process(delta):
	SPEED = min ( SPEED + 250*delta, 300 )
	var output = move_and_collide( direction * SPEED * delta )
	process_collisions(output)

func process_collisions( object ):
	if object == null : return
	if object.collider.is_in_group("obstacles"): return
	if object.collider.is_in_group("enemy_missle"): return
	if object.collider.is_in_group("missle"): get_parent().points += 100
	on_delete()

func on_delete(): 
	call_deferred("queue_free")