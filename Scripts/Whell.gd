extends KinematicBody2D

func _ready():
	base_x = position.x
	base_y = position.y

var base_y = 0
var base_x = 0
var on_floor = false

var max_far = 13

func _physics_process(delta): 
	var collision = move_and_collide( Vector2(0, get_parent().Gravity) * delta )

	if position.y < base_y - 2 * max_far: position.y = base_y - 2 * max_far
	if position.y > base_y + max_far:     position.y = base_y + max_far
	if collision:
		if collision.collider.is_in_group("floor"): on_floor = true
		else : on_floor = false
	else: on_floor = false
	position.x = base_x