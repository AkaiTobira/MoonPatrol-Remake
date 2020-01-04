extends Node

var play_intro    = true
var set_of_spawns = null

var timer_for_segment = -6
var timer_summary     = -6
var timer_reduction   = 0

var drived_road       = 0

# warning-ignore:unused_class_variable
var points            = 0

var logger            = []

var background_backup = null

func _ready():
	Utilities.register_player($Player)
	set_of_spawns = LevelParser.get_active_spawn_times()
	Flow.main_node = self 
	background_backup = $ParallaxBackground.get_backgoround_info()
	Flow.pause_world(3)

func process_intro():
	if not play_intro : return
	play_intro = false
	Flow.play_intro_objects()

func process_timers(delta):
	timer_for_segment += delta
	timer_summary     += delta
	timer_reduction   += Utilities.player.bakcground_speed_multipler * delta * 0.22

func update_logger( info ):
	logger.push_back( info )
	if logger.size() > 8 : logger.pop_front()
	$UI/SpawnLog.text = ""
	for logg in logger:
		$UI/SpawnLog.text += logg + "\n"

func process_spawn():
	var current_time = stepify(drived_road, 0.1)#stepify(timer_for_segment + timer_reduction, 0.1)
	for timer in set_of_spawns :
		var nmb_time = float(timer) * $ParallaxBackground.SPEED * $ParallaxBackground.SPEDD_MULTIPLER_3
		if nmb_time <= current_time: 
			update_logger(str( current_time ) + " " + str(set_of_spawns[timer]))
			parse_keyword( set_of_spawns[timer] )
			set_of_spawns.erase(timer)

func parse_keyword( keyword ):
	if   keyword[0] == "!": print( "Its a warning,       ignore for now" )
	elif keyword[0] == "^": $ParallaxBackground.handle_keyword(keyword)
	elif keyword[0] == "@": $Spawners.spawn_checkpoint( keyword[1] )
	else : $Spawners.spawn_obstacle(keyword)

func parse_checkpoint_keyword(keyword): 
	$Spawners.spawn_checkpoint( keyword[1] )

func _process(delta):
	if Flow.world_is_paused: return
	process_intro()
	process_timers(delta)
	process_spawn()
	process_player_speed(delta)
	process_GUI()
	
func process_GUI(): 
	$UI/Time.text    = str( stepify(timer_for_segment + timer_reduction, 0.1) )
	$UI/GodMode.text = "Good Mode : "  +  str($Player.player_good_mode)
	$UI/Road.text    = str( stepify(drived_road, 0.1) )
	
	if Input.is_action_just_pressed("ui_down"): reload_from_checkpoint()
	if Input.is_action_just_pressed("ui_page_down"): $Player.player_good_mode = !$Player.player_good_mode 
	
	
func process_player_speed(delta):
	var player_multipler = $Player.bakcground_speed_multipler
	$ParallaxBackground.set_speed_multipler( player_multipler )

	if timer_for_segment >= 0 :
		drived_road += $ParallaxBackground.road_speed * delta 

	for obstacle in get_children():
		if obstacle.is_in_group("obstalces"):
			obstacle.adapt_speed( $ParallaxBackground.road_speed )

func reset_segment_process_values():
	timer_for_segment = 0
	timer_reduction   = 0
	drived_road       = 0 
	
func show_game_over():
	
	$UI/Welcomer.text    = "Game Over"
	$UI/Welcomer.visible = true
	Flow.exit_to_intro( 5 )
	pass


func reload_from_checkpoint():
	Flow.clean_scene()
	Utilities.player.reset()
	reset_segment_process_values()
	set_of_spawns     = LevelParser.get_active_spawn_times()
	$ParallaxBackground.set_backgoround_info( background_backup )
	Flow.play_world()

func next_checkpoint(letter):
	background_backup = $ParallaxBackground.get_backgoround_info()
	LevelParser.reached_next_letter(letter)
	set_of_spawns     = LevelParser.get_active_spawn_times()
	reset_segment_process_values()

func _on_V_visibility_changed():
		if $GUI/Control.visible:
			$GUI/Control.hide()
		else: $GUI/Control.show()
