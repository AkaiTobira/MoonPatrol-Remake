extends Node

var play_intro    = true
var set_of_spawns = null

var timer_for_segment = -3.5
var timer_summary     = -3.5

var drived_road       = 0

# warning-ignore:unused_class_variable
var points            = 0
var logger            = []

var background_backup = null

func _ready():
	Utilities.register_player($Player)
	LevelParser.reset()
	set_of_spawns     = LevelParser.get_active_spawn_times()
	Flow.main_node    = self 
	Flow.is_high      = false
	background_backup = $ParallaxBackground.get_backgoround_info()
	reload_background()
	get_tree().call_group("Control", "update_hi_score", Flow.high_score )
	get_tree().call_group("Control", "get_segment_end_distance" )
	Flow.pause_world(2)
	$GUI/Control.get_end_of_main_distance()

func process_intro():
	if not play_intro : return
	play_intro = false
	Flow.play_intro_objects()

func process_timers(delta):
	timer_for_segment += delta
	timer_summary     += delta

func update_logger( info ):
	logger.push_back( info )
	if logger.size() > 8 : logger.pop_front()
	$UI/SpawnLog.text = ""
	for logg in logger:
		$UI/SpawnLog.text += logg + "\n"

func process_spawn():
	var current_time = stepify(drived_road, 0.1)
	for timer in set_of_spawns :
		var nmb_time = float(timer) * Utilities.PIXOMETR
		if nmb_time <= current_time: 
			update_logger(str( current_time ) + " " + str(set_of_spawns[timer]))
			parse_keyword( set_of_spawns[timer] )
			set_of_spawns.erase(timer)

func parse_keyword( keyword ):
	if   keyword[0] == "!": get_tree().call_group("Control", "show_warning", keyword)
	elif keyword[0] == "^": $ParallaxBackground.handle_keyword(keyword)
	elif keyword[0] == "@": $Spawners.spawn_checkpoint( keyword[1] )
	else : $Spawners.spawn_obstacle(keyword)

func parse_checkpoint_keyword(keyword): 
	$Spawners.spawn_checkpoint( keyword[1] )

func _process(delta):
	process_cheat()
	if Flow.world_is_paused: return
	process_intro()
	process_timers(delta)
	process_spawn()
	process_player_speed(delta)
	process_GUI()

var is_frozed = false
func process_cheat():
	if Input.is_action_just_pressed("ui_down"): reload_from_checkpoint()
	if Input.is_action_just_pressed("ui_page_down"): $Player.player_good_mode = !$Player.player_good_mode 

	if Input.is_action_just_pressed("ui_home"): 
		if is_frozed : 
			Flow.unfreeze_screen()
			is_frozed = false
		else :
			Flow.freeze_screen()
			is_frozed = true

	var need_reload = false
	if Input.is_action_just_pressed("res1"): need_reload = LevelParser.change_active_segment( 0 )
	if Input.is_action_just_pressed("res2"): need_reload = LevelParser.change_active_segment( 1 )
	if Input.is_action_just_pressed("res3"): need_reload = LevelParser.change_active_segment( 2 )
	if Input.is_action_just_pressed("res4"): need_reload = LevelParser.change_active_segment( 3 )
	if Input.is_action_just_pressed("res5"): need_reload = LevelParser.change_active_segment( 4 )
	if Input.is_action_just_pressed("res6"): $UI.visible = !$UI.visible
	if need_reload: 
		set_of_spawns = LevelParser.get_active_spawn_times()
		reload_background()
		reload_from_checkpoint()

func process_GUI(): 
	$UI/Time.text    = str( stepify(timer_for_segment, 0.1) )
	$UI/GodMode.text = "Good Mode : "  +  str($Player.player_good_mode)
	$UI/Road.text    = str( stepify(drived_road, 0.1) )
	if Flow.high_score < points: Flow.high_score = points
	get_tree().call_group("Control", "update_hi_score", Flow.high_score)
	get_tree().call_group("Control", "update_score", points)
	get_tree().call_group("Control", "update_drived_distance", drived_road)
	get_tree().call_group("Control", "update_main_distance", drived_road)
	get_tree().call_group("Control", "update_timer", timer_summary)

func process_player_speed(delta):
	var player_multipler = $Player.bakcground_speed_multipler
	$ParallaxBackground.set_speed_multipler( player_multipler )
	update_drived_road(delta)
	for obstacle in get_children():
		if obstacle.is_in_group("obstalces"):
			obstacle.adapt_speed( $ParallaxBackground.road_speed )

func update_drived_road(delta):
	if timer_for_segment < 0 : return
	drived_road += $ParallaxBackground.road_speed * delta 

func reset_segment_process_values():
	timer_for_segment = 0
	drived_road       = 0 

func show_game_over():
	$GUI/Welcomer.text    = "Game Over"
	$GUI/Welcomer.visible = true
	Flow.exit_to_intro( 4 )

func reload_from_checkpoint():
	Flow.clean_scene()
	Utilities.player.reset()
	reset_segment_process_values()
	set_of_spawns     = LevelParser.get_active_spawn_times()
	$ParallaxBackground.set_backgoround_info( background_backup )
	get_tree().call_group("Control", "reset_distance_bar" )
	Flow.play_world()

func reload_background():
	$ParallaxBackground.load_bakcground_fill( LevelParser.get_background_info() )

func next_checkpoint(letter):
	background_backup = $ParallaxBackground.get_backgoround_info()
	LevelParser.reached_next_letter(letter)
	set_of_spawns     = LevelParser.get_active_spawn_times()
	get_tree().call_group("Control", "get_segment_end_distance" )
	reset_segment_process_values()

func _on_V_visibility_changed():
		if $GUI/Control.visible:
			$GUI/Control.hide()
		else: $GUI/Control.show()

func play_sound_of_death(death_sound):
	if death_sound > 0: $AlienDestroyed.play()
