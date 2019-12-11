extends Node

var play_intro    = true
var player_points = 0 

var set_of_spawns = null

var timer_for_segment = -6
var timer_summary     = -6

var points            = 0

func _ready():
	Common.player  = $Player
	set_of_spawns = Common.get_active_spawn_times()
	Flow.main_node = self 
	Flow.pause_world(3)

func process_intro():
	if not play_intro : return
	play_intro = false
	Flow.play_intro_objects()

func process_timers(delta):
	timer_for_segment += delta
	timer_summary     += delta

func process_spawn():
	var current_time = stepify(timer_for_segment, 0.1)
	for timer in set_of_spawns :
		var nmb_time = float(timer)
		if nmb_time <= current_time:
			parse_keyword( set_of_spawns[timer] )
			set_of_spawns.erase(timer)

func parse_keyword( keyword ):
	if   keyword[0] == "!": print( "Its a warning,       ignore for now" )
	elif keyword[0] == "^": print( "Its a RoadConroller, ignore for now" )
	elif keyword[0] == "@": $Spawners.spawn_checkpoint( keyword[1] )
	else : $Spawners.spawn_obstacle(keyword)

func parse_checkpoint_keyword(keyword): 
	$Spawners.spawn_checkpoint( keyword[1] )

func _process(delta):
	if Flow.world_is_paused: return
	process_intro()
	process_timers(delta)
	process_spawn()
	process_player_speed()
	process_GUI()
	
func process_GUI(): pass
	
func process_player_speed():
	var player_multipler = $Player.bakcground_speed_multipler
	$ParallaxBackground.set_speed_multipler( player_multipler )
#	time_reduciton += player_multipler * delta * 0.2
	
	for obstacle in get_children():
		if obstacle.is_in_group("obstalces"):
			obstacle.adapt_speed( $ParallaxBackground.road_speed )

func reload_from_checkpoint():
	Flow.clean_scene()
	timer_for_segment = 0
	Common.player.reset()
	set_of_spawns     = Common.get_active_spawn_times()
#	Flow.play_world()

func next_checkpoint(letter):
	Common.reached_next_letter(letter)
	set_of_spawns     = Common.get_active_spawn_times()
	timer_for_segment = 0 