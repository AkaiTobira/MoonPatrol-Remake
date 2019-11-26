extends "res://Scripts/Alien_Base.gd"

var bomb = null

func _ready():
	._ready()
	operative_space = { "LT" : Vector2(max( Common.player.move_borders.x - 100, 550 ), 300 ),
                        "RD" : Vector2(Common.player.move_borders.y + 800, 400 ) }
	MAX_PRECISION          = 500
	DISTANCE_FOR_NEW_POINT = 400
	move_speed             = 350
	PRECISION_UPDATE       = 0
	SHOOT_PROBABILITY      = 250
	KAMIKAZE_ENABLED       = false
	LIFE_TIME              = 12

func _physics_process(delta):
	update_times(delta)
	process_dead()
	process_bombing()
	process_move(delta)

func process_bombing():
	if can_shoot():
		get_parent().active_squats[squat_id][1] = true
		bomb = Common.get_instance("Bomb")
		bomb.calculate_path( self )
		get_parent().call_deferred( "add_child", bomb )

func can_shoot():
	if bomb != null : return false
	if get_parent().active_squats[squat_id][1]: return false
	if position.x < Common.player.move_borders.y : return false
	if randi()%SHOOT_PROBABILITY != 0 : return false
	return true

func on_destroy():
	if bomb: bomb.bomber = null
	.on_destroy()

func on_dead():
	if bomb: bomb.bomber = null
	.on_dead()
