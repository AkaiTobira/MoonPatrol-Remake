extends Node2D
 
var points         = 0
var player_letter  = 0

var current_level  = "1"
var background_settings = []
var current_segment     = {}
var next_letter    = 64

var intro_timer       = 0
var intro_time_lenght = 5


var time_whole     = - 10
var time_segment   = - 10
var time_reduciton = 0

#system variavles
var loger          = []
var MAX_LOG_INFO   = 8
var pause          = false
var intro_end      = false

func _ready():
	player_reached_next_letter()
	current_level   = Common.get_start_id()
	current_segment = Common.get_level_segment(current_level)
	Common.register_player( $Player )
	pause_world()
	

func player_reached_next_letter():
	get_next_segment()
	player_letter  = next_letter
	next_letter    = next_letter + 1
	loger.append("\n Segment :" + current_level + " : " + char(next_letter)  ) 
	loger.append( "\n Player point : " + char(player_letter) )
	update_log()
	background_settings = $ParallaxBackground.get_backgoround_info()
	if player_letter%5 == 4 and player_letter > 65  : update_segment()
	$GUI/Control/Warnings/Checkpoint.text = char(next_letter)

func get_next_segment():
	update_segment_index()
	current_segment = Common.get_level_segment(current_level)

func update_segment_index():
	if Common.is_level_fixed(): return
	elif Common.is_randomized(): Common.level_list.shuffle()
	if len(Common.level_list): current_level = Common.level_list.pop_front()

func update_log():
	$UI/SpawnLog.text = "SPAWN LOG"
	while len(loger) > MAX_LOG_INFO: loger.pop_front()
	for text in loger: $UI/SpawnLog.text += text

func update_segment():
	pause_world()
	$Summary.start_typing_sequences( player_letter, { "takes_time"   : time_whole, 
	                                                  "top_time"     : Common.get_record_info()[0], 
													  "average_time" : Common.get_record_info()[1] } )
	clean_scene()
	Common.switch_to_next_segment()
	current_level   = Common.get_start_id()
	current_segment = Common.get_level_segment(current_level)
	loger = ["","","","","","","",""]
	update_log()
	time_whole = 0
	$ParallaxBackground.load_bakcground_fill( Common.get_segment_texture() )
#	print ( " here is going next level and summary but it is not implemented " )
#	$Spawners.spawn_reached_checkpoint( char(player_letter) )
	
	
func restart_game():
		if points > Common.high_score: Common.high_score = points 
		clean_scene()
		Common.sqgment_id = 1
		next_letter   = 64
		player_letter  = next_letter
		next_letter    = next_letter + 1
		reload_from_checkpoint()

func check_intro():
	if intro_timer < intro_time_lenght: return
	if intro_end : return
	turn_down_intro()

func _process(delta):
#	if Input.is_action_just_pressed("ui_accept"): 

	update_time(delta)
	check_intro()
	if pause: return
	update_move_speed(delta)
	update_points()
	process_spawn()
	handle_segment_end()

func update_time(delta):
	intro_timer  += delta
	if pause: return
	time_segment += delta
	time_whole   += delta

	$UI/MainTimeCounter.text = "TIME SINCE BEGIN : " + str(stepify(time_whole, 0.1)) 
	$UI/Time.text = "TIME :" + str(stepify(time_segment, 0.1)) + " +" + str(stepify(time_reduciton, 0.1))
	$GUI/Control/ScoreBoard/GTime.text = str(stepify(time_whole,0.1))
	

func turn_down_intro():
	$UI/Welcomer.visible = false
	intro_end            = true
	$Base.play()
	play_world()

func update_move_speed(delta):
	var player_multipler = $Player.bakcground_speed_multipler
	$ParallaxBackground.set_speed_multipler( player_multipler )
	time_reduciton += player_multipler * delta * 0.2
	
	for obstacle in get_children():
		if obstacle.is_in_group("obstalces"):
			obstacle.set_speed_multipler( player_multipler )

func update_points():
	if points > Common.high_score: Common.high_score = points 
	$UI/Score.text     = "SCORE :"     + str(points)
	$UI/HighScore.text = "HIGHSCORE :" + str(Common.high_score)
	$GUI/Control/ScoreBoard/ScoreResult.text = str(points)
	$GUI/Control/ScoreBoard/HiScoreResult.text = str(Common.high_score)
	

func process_spawn():
	var parsed_time = stepify(time_segment + time_reduciton, 0.1)
	for timer in current_segment["spawn_times"] :
		var nmb_time = float(timer)
		if nmb_time <= parsed_time:
			var obstacle_to_spawn = current_segment["spawn_times"][timer] 
			loger.append( "\n " + obstacle_to_spawn + ": " + str(stepify(time_segment, 0.1)) )
			$Spawners.spawn_obstacle(obstacle_to_spawn)
			current_segment["spawn_times"].erase(timer)
			update_log()

func handle_segment_end():
	if time_segment + time_reduciton > current_segment["duration"]:
		$Spawners.spawn_checkpoint(char(next_letter))
		reset_timers(-5)

func reset_timers( default = 0 ):
	time_segment   = default
	time_reduciton = 0

func reload_from_checkpoint():
	reset_timers()
	clean_scene()
	spawn_checpoint()
	reload_level_info()
	play_world()

func clean_scene():
	SquatController.clear()
	for obstacle in get_children():
		if obstacle.is_in_group("enemy_missle"):
			obstacle.call_deferred( "queue_free" )
		if obstacle.is_in_group("obstalces"):
			obstacle.call_deferred( "queue_free" )
	$Player.reset()

func spawn_checpoint():
	if player_letter != 64:
		$Spawners.spawn_reached_checkpoint( char(player_letter) )

func reload_level_info():
	$ParallaxBackground.set_backgoround_info(background_settings)
	loger.append("\n Player dead \n reload from : " + str(current_level) )
	current_segment = Common.get_level_segment(current_level)
	next_letter     = player_letter + 1
	update_log()

func play_world():
	pause = false
	$ParallaxBackground.play()
	$Player.play()

func pause_world():
	pause = true
	$ParallaxBackground.stop()
	$Player.stop()
	for obstacle in get_children():
		if obstacle.is_in_group("obstalces"):
			obstacle.call_deferred( "stop" )
