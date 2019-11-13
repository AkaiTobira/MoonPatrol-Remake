extends KinematicBody2D

export var Gravity   =  100.0
export var MaxJump   =  300.0
export var Friction  =  100.0
export var MoveSpeed =  200.0

var directions = { "left" : Vector2(-1,0), "right" : Vector2(1,0) }
var direction  = Vector2(0,0)

var jump            = 100.0
var right_border    = 800.0
var base_position_x = position.x
var on_ground       = false

func _ready(): pass

func move_verticall(delta):
	var jump_force  = calculate_jump_force(delta)
	if !test_move( get_transform(), jump_force * delta ):
# warning-ignore:return_value_discarded
		move_and_collide( jump_force * delta )
		return false
	return true

func move_horizontal(delta):
	var speed    = calculate_speed()
	var friction = calculate_friction()
# warning-ignore:return_value_discarded
	move_and_collide( ( friction + speed) * delta )

func calculate_jump_force(delta):
	if jump == 0 : return Vector2(0, Gravity)
	jump = max( jump - Gravity*delta, 0 )
	return Vector2(0, - jump) + Vector2(0, Gravity)

func calculate_speed():
	if position.x < right_border: return direction * MoveSpeed
	return Vector2(0,0)

func calculate_friction():
	if position.x > base_position_x: return Vector2( -Friction, 0 )
	return Vector2(0,0)

func should_stop_near_right_border():
	return position.x >= right_border and direction == directions["right"]

func process_moves(delta):
	on_ground = move_verticall(delta)
	if !on_ground: return
	if should_stop_near_right_border(): return
	move_horizontal(delta)

# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("ui_select") and jump == 0: jump = MaxJump
	direction  = Vector2(0,0)
	if Input.is_action_pressed("ui_right") : direction = directions["right"]
	if Input.is_action_pressed("ui_left")  and position.x >= base_position_x:  direction = directions["left"]

func _physics_process(delta):
	process_moves(delta)

func _on_Area2D_body_entered(body):
	if body.is_in_group("obstalces"):
		print( "RIP, player died" )
