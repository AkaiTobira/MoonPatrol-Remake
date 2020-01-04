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
var relative_y = 0
var is_jumping = false

onready var base_high  = position.y

var force      = 0
var on_floor   = true
var floor_y    = 0

var lives      = 2

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
	relative_x = 0
	relative_y = 0
	position.y = base_high
	
	if get_parent().background_backup[ 3 ] : position.y -= 200
	
	forward_missle  = null
	fire_up_missles = 0 
	relative_x = 0

func shoot_forward():
	forward_missle            = Utilities.get_instance("PFmissle")
	forward_missle.position   = position + Vector2(100,-20)
	forward_missle.scale      = Vector2( 1, 0.5 )
	forward_missle.life_range = 300 
	forward_missle.direction  = Vector2(1,0)
	get_parent().call_deferred("add_child", forward_missle)  
	$ShootSound.play()
	

func shoot_up():
	var up_missle        = Utilities.get_instance("PUmissle")
	up_missle.position   = position + Vector2(-30,-30)
	up_missle.life_range = 600 
	up_missle.direction  = Vector2(0,-1)
	get_parent().call_deferred("add_child", up_missle)

func play(): 
	pause = false
	
func stop(): 
	pause = true

func _physics_process(delta):
	if pause: return
	process_move(delta)
	process_wheels()

# warning-ignore:unused_argument
func process_wheels():
	$Whell1/AnimationPlayer.playback_speed = 1 + bakcground_speed_multipler
	$Whell2/AnimationPlayer.playback_speed = 1 + bakcground_speed_multipler
	 
#Whole function is to refactor but it is work
func process_move(delta):
	var middle_point     = ( move_borders.x + move_borders.y )/2
	var movable_distance = move_borders.y - move_borders.x
	var target_pos = Vector2( middle_point + (relative_x * movable_distance)/100, 
	                          relative_y )
# warning-ignore:return_value_discarded
	move_and_slide( Vector2(target_pos.x, position.y) - position )

	var gravity_reducer = min( 1, ( Vector2(position.x, target_pos.y) - position ).length() / MaxJump + 0.3 )
# warning-ignore:return_value_discarded
	if is_jumping: move_and_slide( ( Vector2(position.x, target_pos.y) - position ).normalized() * Gravity * gravity_reducer  )
	else:
		on_floor = wheel_on_floor(move_and_collide( Vector2(0, Gravity) * delta * gravity_reducer ))
#		if collision:
#			if collision.collider.is_in_group("floor"): on_floor = true

	bakcground_speed_multipler = 1 + ( relative_x/200 )

func wheel_on_floor( collision ):
	if collision : 
		return $Whell1.on_floor or $Whell2.on_floor or collision.collider.is_in_group("floor")
	return $Whell1.on_floor or $Whell2.on_floor

func on_dead():
	if not player_good_mode: 
		$ExplosionSound.play()
		Flow.pause_world(10)
		play_animation_if_not_player("Dead")

func play_animation_if_not_player( anim_name ):
	if $AnimationPlayer.current_animation == anim_name : return
	$AnimationPlayer.play(anim_name)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Dead": 
		lives -= 1
		play_animation_if_not_player( "Idle" )
		Flow.play_world()
		if lives < 0 and not player_good_mode : 
			Flow.pause_world(1000)
			get_parent().show_game_over()
			visible = false
		else : get_parent().reload_from_checkpoint()


func _on_Area2D_body_entered(body):
	var is_killed = body.is_in_group("alien") or body.is_in_group("enemy_missle")
	var hit_smt   = body.is_in_group("obstalces") 
	if hit_smt:     body.on_delete()
	if is_killed or hit_smt: on_dead()
