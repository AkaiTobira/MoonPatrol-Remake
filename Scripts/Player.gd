extends KinematicBody2D

# warning-ignore:unused_class_variable
export var Gravity      =  900.0
# warning-ignore:unused_class_variable
export var MaxJump      =  60.0
# warning-ignore:unused_class_variable
export var Friction     =  50.0
# warning-ignore:unused_class_variable
export var MaxMoveSpeed =  130.0
export var move_borders = Vector2( 500, 800 )


#shooting variables
var forward_missle  = null
var fire_up_missles = 0

#system variables
var bakcground_speed_multipler = 0
var player_good_mode           = true
var pause                      = false

# warning-ignore:unused_class_variable
var relative_x = 0
var force      = 0
var on_floor   = false
var controller = null

func _ready():
	calculate_relative()
	controller = load( "res://Scripts/PlayerControlSFSM.gd" ).new()
	add_child(controller)

func calculate_relative():
	var middle_point     = ( move_borders.x + move_borders.y )/2
	var movable_distance = move_borders.y - move_borders.x
	relative_x = (position.x - middle_point)/movable_distance  * 100

func reset():
	forward_missle  = null
	fire_up_missles = 0 
	relative_x = 0

func shoot_forward():
	forward_missle            = Common.get_instance("PFmissle")
	forward_missle.position   = position + Vector2(30,0)
	forward_missle.scale      = Vector2( 1, 0.5 )
	forward_missle.life_range = 300 
	forward_missle.direction  = Vector2(1,0)
	get_parent().call_deferred("add_child", forward_missle)  

func shoot_up():
	var up_missle        = Common.get_instance("PUmissle")
	up_missle.position   = position + Vector2(-30,-30)
	up_missle.life_range = 600 
	up_missle.direction  = Vector2(0,-1)
	get_parent().call_deferred("add_child", up_missle)

func play(): 
	pause = false
	controller.play()
	
func stop(): 
	pause = true
	controller.stop()

func _physics_process(delta):
	if pause: return
	new_moves(delta)
	#process_moves(delta)

#Whole function is to refactor but it is work
func new_moves(delta):
	var middle_point     = ( move_borders.x + move_borders.y )/2
	var movable_distance = move_borders.y - move_borders.x

	if not on_floor:
		var collision = move_and_collide( Vector2(0, -force ) * delta )
		if collision:
			if collision.collider.is_in_group("floor"): on_floor = true

	var target_pos = Vector2( middle_point + (relative_x * movable_distance)/100, position.y )
# warning-ignore:return_value_discarded
	move_and_slide( target_pos - position )

	#fix for not straight road
	if !test_move( get_transform(), Vector2(0, 1 ) ) and on_floor:
# warning-ignore:return_value_discarded
		move_and_slide( Vector2( 0, Gravity) )

	bakcground_speed_multipler = 1 + relative_x/100

func on_dead():
	if not player_good_mode: 
		get_parent().pause_world()
		print( "Here should be break but since player has no animation it isn't" )
		get_parent().reload_from_checkpoint()

func _on_Area2D_body_entered(body):
	if body.is_in_group("alien"):
		on_dead()
		print( "RIP, player died by kamikaze" )
	if body.is_in_group("obstalces"):
		on_dead()
		print( "RIP, player died by obstacles" )
	if body.is_in_group("enemy_missle"):
		on_dead()
		print( "RIP, player died by missle" )

