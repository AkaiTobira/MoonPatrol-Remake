extends "res://Scripts/Alien_Base.gd"

var bomb            = null
var move_log        = []
var is_squat_lider  = false
var lider           = null
var number_in_squat = 1
var steps           = 0

func _ready():
	._ready()
	operative_space = { "LT" : Vector2(max( Utilities.player.move_borders.x - 100, 550 ), 300 ),
                        "RD" : Vector2(Utilities.player.move_borders.y + 800, 400 ) }
	MAX_PRECISION          = 500
	DISTANCE_FOR_NEW_POINT = 400
	move_speed             = 350
	PRECISION_UPDATE       = 0
	SHOOT_PROBABILITY      = 1
	POINTS_FOR_DESTROY     = 200
	KAMIKAZE_ENABLED       = false
	LIFE_TIME              = 12
	
# warning-ignore:unused_variable
	for i in range(76): move_log.append(Vector2(0,0))

func _physics_process(delta):
	if Flow.world_is_paused : return
	update_times(delta)
	process_dead()
	process_bombing()
	if is_squat_lider or is_dead:
		process_move(delta)
	else: 
		if steps > ( number_in_squat * 15):
			follow_lider(delta)
		else: process_move(delta)
	update_move_log()

func follow_lider(delta):
	target_move_point = lider.move_log[ number_in_squat * 15 ] 
	move_to_target_pos(delta)
	avoid = false

func update_move_log():
	move_log.append(position)
	if move_log.size() > 76: move_log.pop_front()
	steps+=1

func process_bombing():
	if can_shoot():
		bomb = Utilities.get_instance("Bomb")
		bomb.calculate_path( self )
		SquatController.fire_bomb(squat_id, bomb)
		get_parent().call_deferred( "add_child", bomb )

func can_shoot():
	if bomb != null : return false
	if SquatController.is_sqaut_special_active( squat_id ): return false
	if position.x < Utilities.player.move_borders.y : return false
	if randi()%SHOOT_PROBABILITY != 0 : return false
	return true

func on_destroy():
	SquatController.bomber_destroyed( squat_id, number_in_squat-1 )
	.on_destroy()

func on_delete():
	SquatController.bomber_destroyed( squat_id, number_in_squat-1 )
	.on_delete()
