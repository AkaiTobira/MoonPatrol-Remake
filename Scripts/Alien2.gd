extends "res://Scripts/Alien_Base.gd"

func _ready():
	._ready()
	operative_space = { "LT" : Vector2(max( Utilities.player.move_borders.x - 100, 450 ), 200 ),
                        "RD" : Vector2(Utilities.player.move_borders.y + 300, 600 ) }
	MAX_PRECISION     = 500
	move_speed        = 250
	PRECISION_UPDATE  = 30
	SHOOT_PROBABILITY = 320
	KAMIKAZE_ENABLED  = true
	LIFE_TIME         = 8
	
func _physics_process(delta):
	if Flow.world_is_paused : return
	update_times(delta)
	process_dead()
	process_shooting()
	process_move(delta)
