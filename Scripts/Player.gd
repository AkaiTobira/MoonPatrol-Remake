extends Area2D

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
var player_good_mode           = false
var pause                      = false

# warning-ignore:unused_class_variable
var relative_x = 0
var relative_y = 0
var is_jumping = false

onready var base_high  = position.y

var on_floor   = true

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

	if Flow.is_high : position.y -= ( Flow.hight_difference + 10 )
	
	forward_missle  = null
	fire_up_missles = 0 
	relative_x      = 0
	pause           = false
	is_jumping      = false
	on_floor        = true


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
	up_missle.position   = position + Vector2(-75,-30)
	up_missle.life_range = 600 
	up_missle.direction  = Vector2(0,-1)
	get_parent().call_deferred("add_child", up_missle)

func play(): 
	pause = false

func stop(): 
	pause = true

func _physics_process(delta):
	if Flow.world_is_paused : return 
	if pause: return
	process_move(delta)
	process_wheels()

# warning-ignore:unused_argument
func process_wheels():
	$Whell1/AnimationPlayer.playback_speed = 1 + bakcground_speed_multipler
	$Whell2/AnimationPlayer.playback_speed = 1 + bakcground_speed_multipler
	 
	
onready var wheel_base = ( $Whell1.position + $Whell2.position ) / 2.0
#Whole function is to refactor but it is work
func process_move(delta):
	if Flow.world_is_paused : return 
	var middle_point     = ( move_borders.x + move_borders.y )/2
	var movable_distance = move_borders.y - move_borders.x
	var target_pos = Vector2( middle_point + (relative_x * movable_distance)/100, 
	                          relative_y )
# warning-ignore:return_value_discarded

	var res            = Vector2(target_pos.x, position.y) - position
	var wheel_distance = ( $Whell1.position + $Whell2.position ) / 2.0
	
	position.x += res.x * delta
	position.y += (wheel_distance - wheel_base).y

	if is_jumping : switch_wheels(true)
	else: on_floor = wheel_on_floor()

	bakcground_speed_multipler = 1 + ( relative_x/200 )

func switch_wheels( is_gravity_reverted ):
	$Whell1.reverse_gravity = is_gravity_reverted
	$Whell2.reverse_gravity = is_gravity_reverted

func wheel_on_floor():
	switch_wheels(false)
	return $Whell1.on_floor or $Whell2.on_floor

func on_dead():
	if not player_good_mode: 
		controller.set_process(false)
		Flow.stop_BGM_music()
		$ExplosionSound.play()
		Flow.pause_world(10)
		play_animation_if_not_player("Dead")

func play_animation_if_not_player( anim_name ):
	if $AnimationPlayer.current_animation == anim_name : return
	$AnimationPlayer.play(anim_name)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Dead": 
		lives -= 1
		get_tree().call_group("Control", "update_lives", lives)
		play_animation_if_not_player( "Idle" )
		Flow.play_world()
		if lives < 0 and not player_good_mode : 
			Flow.pause_world(1000)
			get_tree().call_group("Control", "update_lives", "0")
			$DeadSound.play()
			get_parent().show_game_over()
			visible = false
		else : 
			get_parent().reload_from_checkpoint()
			Flow.play_BGM_music()
		controller.set_process(true)


func play_end_game_music():
	$VictorySound.play()
	
func play_checkpoint_music():
	$LoseLifeSound.play()

func block_player_animations():
	$AnimationPlayer.stop()
	$Whell1/AnimationPlayer.stop()
	$Whell2/AnimationPlayer.stop()

func play_player_animations():
	$AnimationPlayer.play()
	$Whell1/AnimationPlayer.play()
	$Whell2/AnimationPlayer.play()

func _on_Area2D_body_entered(body):
	var is_killed = body.is_in_group("alien") or body.is_in_group("enemy_missle")
	var hit_smt   = body.is_in_group("obstalces") 
	if hit_smt:     body.on_delete()
	if is_killed or hit_smt: on_dead()

func _on_Sound_finished():
	Flow.summarize()
