extends KinematicBody2D

export var Gravity   =  100.0
export var MaxJump   = -200.0
export var Friction  =  100.0
export var MoveSpeed =  150.0

var jump            = 100.0
var right_border    = 800.0
var right_shift     = 0.0
var base_position_x = position.x

func _ready(): pass

func handle_gravity(delta):
	if jump != 0 : jump += Gravity*delta

func handle_friction(delta):
	if right_shift != 0: right_shift = max( right_shift - Friction * delta, 0 )

func handle_move(delta):
	if !jump: position = Vector2( base_position_x  + right_shift, position.y )
	if ( move_and_collide( Vector2(0, 1 * jump) * delta ) ) : jump = 0

func _process(delta):
	if Input.is_action_just_pressed("ui_select") and jump == 0: jump = MaxJump
	if Input.is_action_pressed("ui_right"):  right_shift = min( right_shift + MoveSpeed * delta * 1.25, right_border )
	if Input.is_action_pressed("ui_left"):   right_shift = max( right_shift - MoveSpeed * delta, 0 )
	print( right_shift )

func _physics_process(delta):
	handle_gravity(delta)
	handle_friction(delta)
	handle_move(delta)
