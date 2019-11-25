extends "res://Scripts/Alien_Base.gd"

func _ready():
	._ready()
	operative_space = { "LT" : Vector2(max( player.move_borders.x - 100, 450 ), 300 ),
                        "RD" : Vector2(player.move_borders.y + 300, 450 ) }
	MAX_PRECISION     = 250
	PRECISION_UPDATE  = 30
	SHOOT_PROBABILITY = 320
	KAMIKAZE_ENABLED  = true
	LIFE_TIME         = 12
	
func _physics_process(delta):
	update_times(delta)
	process_dead()
	process_shooting()
	process_move(delta)