extends KinematicBody2D

export var Gravity   =  100.0
export var MaxJump   =  300.0
export var Friction  =  100.0
export var MoveSpeed =  200.0

onready var missle = load( "res://Scenes/Missle.tscn" )
onready var fmissle = load( "res://Scenes/Missle_forward.tscn" )
var forward_missle = null

var directions = { "left" : Vector2(-1,0), "right" : Vector2(1,0) }
var direction  = Vector2(0,0)

var jump            = 100.0
var right_border    = 450.0
onready var base_position_x = position.x
var on_ground       = false

var bakcground_speed_multipler = 0

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
	update_backgound_multipler()

func update_backgound_multipler():
	var offset = 50
	var full_range = right_border - base_position_x - offset
	bakcground_speed_multipler =  min( max( (position.x-base_position_x - offset)/full_range, 0 ), 1 )

func shoot_forward():
	if forward_missle: return
	forward_missle            = fmissle.instance()
	forward_missle.position   = position + Vector2(30,0)
	forward_missle.scale      = Vector2( 1, 0.5 )
	forward_missle.life_range = 300 
	forward_missle.direction  = Vector2(1,0)
	get_parent().call_deferred("add_child", forward_missle)  

func shoot_up():
	var up_missle        = missle.instance()
	up_missle.position   = position + Vector2(-30,-30)
	up_missle.life_range = 400 
	up_missle.direction  = Vector2(0,-1)
	get_parent().call_deferred("add_child", up_missle)

func shoot(): 
	shoot_forward()
	shoot_up()

# warning-ignore:unused_argument
func _process(delta):
	if Input.is_action_just_pressed("ui_up") and jump == 0: jump = MaxJump
	direction  = Vector2(0,0)
	if Input.is_action_pressed("ui_right") : direction = directions["right"]
	if Input.is_action_pressed("ui_left")  and position.x >= base_position_x:  direction = directions["left"]
	if Input.is_action_just_pressed("ui_accept"): shoot()

func _physics_process(delta):
	process_moves(delta)

func _on_Area2D_body_entered(body):
	if body.is_in_group("obstalces"):
		print( "RIP, player died" )
