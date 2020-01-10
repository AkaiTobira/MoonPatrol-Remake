extends KinematicBody2D

func _ready():
	base_x = position.x
	base_y = position.y

var base_y = 0
var base_x = 0
var on_floor = false

var reverse_gravity = false

func _physics_process(delta): 
	if Flow.world_is_paused : return
	var gravity = 35
	var collision = null
	if reverse_gravity : gravity = -gravity
	
	collision = move_and_collide( Vector2(0, gravity) * delta )
	if collision:
		if collision.collider.is_in_group("floor"): on_floor = true
		else : on_floor = false
	else: on_floor = false

	if abs( position.x - base_x ) > 10 : position.x = base_x