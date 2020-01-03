extends KinematicBody2D

func _ready():
	base_x = position.x
	base_y = position.y

var base_y = 0
var base_x = 0
var on_floor = false

var max_far = 13

var reverse_gravity = false

func _physics_process(delta): 
#	if get_parent().is_jumping: return
	var gravity = 15
	var collision = null
	if reverse_gravity : gravity = -gravity
	
	collision = move_and_collide( Vector2(0, gravity) * delta )
	if collision:
		if collision.collider.is_in_group("floor"): on_floor = true
		else : on_floor = false
	else: on_floor = false

#	position = Vector2( base_x, base_y )

#	if position.y < base_y - max_far: position.y = base_y - max_far
#	if position.y > base_y + max_far: position.y = base_y + max_far
#	position.x = base_x