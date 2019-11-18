extends Node2D
 
var background_settings = []
var current_segment     = {}
var dict                = {}

var current_level  = "1"
var level_list     = []

var points         = 0

var time_whole     = 0
var time           = -5
var time_reduciton = 0

var loger          = []
var MAX_LOG_INFO   = 8

var current_letter = 64
var player_letter  = 0
var next_letter    = 65

var pause          = false

func _ready():
	load_level_structure()
	current_level   = dict["start_segment"]
	parse_level_list()
	player_reached_next_letter()
	current_segment = dict["level_structure"][current_level].duplicate(true)

func parse_level_list():
	for level in dict["level_structure"].keys():
		if level == dict["start_segment"]: continue
		level_list.append(level)

func load_level_structure():
	var file = File.new()
	file.open("res://Resouces/LevelStructure.json", file.READ)
	dict = parse_json(file.get_as_text())
	file.close()
	assert( dict != null )

func update_log():
	$UI/SpawnLog.text = "SPAWN LOG"
	while len(loger) > MAX_LOG_INFO: loger.pop_front()
	for text in loger: $UI/SpawnLog.text += text
	
func update_segment_index():
	if dict["fixed_segment"]: return
	elif dict["random_order"]: level_list.shuffle()
	if len(level_list): current_level = level_list.pop_front()

func get_next_segment():
	update_segment_index()
	current_segment = dict["level_structure"][current_level].duplicate(true)
	$Checkpoint_Spawner.spawn(char(next_letter))
	current_letter = next_letter
	next_letter    = next_letter + 1
	loger.append("\n Segment :" + current_level + " : " + char(next_letter)  ) 

func spawn_obstacle(obstacle_to_spawn):
	match obstacle_to_spawn:
		"Rock" : 
			$Rock_Spawner.spawn()
			loger.append( "\n Rock : " + str(stepify(time, 0.1)) )
		"Hole" : 
			$Hole_Spawner.spawn()
			loger.append( "\n Hole : " + str(stepify(time, 0.1)) )
		"Mine" : 
			$Mine_Spawner.spawn()
			loger.append( "\n Mine : " + str(stepify(time, 0.1)) )
		_ :
			print( "ERROR : not found" ,time , " is " , obstacle_to_spawn , " And this is unknown" )
			assert(true == false)

func process_spawn():
	var parsed_time = stepify(time + time_reduciton, 0.1)
	for timer in current_segment["spawn_times"] :
		var nmb_time = float(timer)
		if nmb_time <= parsed_time:
			var obstacle_to_spawn = current_segment["spawn_times"][timer] 
			spawn_obstacle(obstacle_to_spawn)
			current_segment["spawn_times"].erase(timer)
			update_log()

func update_time(delta):
	if pause: return
	time       += delta
	time_whole += delta
	
	$UI/MainTimeCounter.text = "TIME SINCE BEGIN : " + str(stepify(time_whole, 0.1)) 
	$UI/Time.text = "TIME :" + str(stepify(time, 0.1)) + " +" + str(stepify(time_reduciton, 0.1))
	
func process_segment_end():
	if time + time_reduciton > current_segment["duration"]: 
		get_next_segment()
		reset_timers(-5)

func update_move_speed(delta):
	var player_multipler = $Player.bakcground_speed_multipler
	$ParallaxBackground.set_speed_multipler( player_multipler )
	time_reduciton += player_multipler * delta * 0.2
	
	for obstacle in get_children():
		if obstacle.is_in_group("obstalces"):
			obstacle.set_speed_multipler( player_multipler )

func player_reached_next_letter():
	player_letter = current_letter
	loger.append( "\n Player point : " + char(player_letter) )
	update_log()
	background_settings = $ParallaxBackground.get_backgoround_info()

func clean_scene():
	for obstacle in get_children():
		if obstacle.is_in_group("obstalces"):
			obstacle.call_deferred( "queue_free" )
	$Player.reset_position()

func create_current_checkpoint_mark():
	var checkpoint_marker =  load( "res://Scenes/Checkpoint.tscn" ).instance()
	checkpoint_marker.set_letter(char(player_letter))
	checkpoint_marker.fixed_y_pos = $Checkpoint_Spawner.position.y
	checkpoint_marker.position.x  = $Player.base_position_x + 150
	call_deferred("add_child", checkpoint_marker ) 

func reload_level():
	$ParallaxBackground.set_backgoround_info(background_settings)
	loger.append("\n Player dead \n reload from : " + str(current_level) )
	current_segment = dict["level_structure"][current_level].duplicate(true)

func reset_timers( default = 0 ):
	time           = default
	time_reduciton = 0

func reload_from_checkpoint():
	reset_timers()
	clean_scene()
	create_current_checkpoint_mark()
	reload_level()
	play_world()

func update_points():
	$UI/Score.text = "SCORE :" + str(points)

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

func _process(delta):
	update_time(delta)
	if pause: return
	update_move_speed(delta)
	update_points()
	process_spawn()
	process_segment_end()
	
#https://strategywiki.org/wiki/Moon_Patrol/Walkthrough
