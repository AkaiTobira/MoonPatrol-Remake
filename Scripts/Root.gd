extends Node2D
 
#TODO when restarts will be enabled
# warning-ignore:unused_class_variable
var background_settings = {} 
var current_segment     = {}
var dict                = {}

var current_level  = "1"
var level_list     = []
var time           = 0
var time_reduciton = 0

var loger = []
var MAX_LOG_INFO = 8

func _ready():
	load_level_structure()
	current_level   = dict["start_segment"]
	parse_level_list()
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
	$SpawnLog.text = "SPAWN LOG"
	while len(loger) > MAX_LOG_INFO: loger.pop_front()
	for text in loger: $SpawnLog.text += text
	
func update_segment_index():
	if dict["fixed_segment"]: return
	elif dict["random_order"]: level_list.shuffle()
	if len(level_list): current_level = level_list.pop_front()

func get_next_segment():
	update_segment_index()
	current_segment = dict["level_structure"][current_level].duplicate(true)
	loger.append("\n Segment :" + current_level ) 

func spawn_item(item_to_spawn):
	match item_to_spawn:
		"Rock" : 
			$Rock_Spawner.spawn()
			loger.append( "\n Rock : " + str(stepify(time, 0.1)) )
		"Hole" : 
			$Hole_Spawner.spawn()
			loger.append( "\n Hole : " + str(stepify(time, 0.1)) )
		_ :
			print( "ERROR : not found" ,time , " is " , item_to_spawn , " And this is unknown" )
			assert(true == false)

func process_spawn():
	var parsed_time = stepify(time + time_reduciton, 0.1)
	for timer in current_segment["spawn_times"] :
		var nmb_time = float(timer)
		if nmb_time <= parsed_time:
			var item_to_spawn = current_segment["spawn_times"][timer] 
			spawn_item(item_to_spawn)
			current_segment["spawn_times"].erase(timer)
			update_log()

func update_time(delta):
	time += delta
	$Time.text = "TIME :" + str(stepify(time, 0.1)) + " -" + str(stepify(time_reduciton, 0.1))
	
func process_segment_end():
	if time + time_reduciton > current_segment["duration"]: 
		get_next_segment()
		time           = 0
		time_reduciton = 0 

func update_move_speed(delta):
	var player_multipler = $Player.bakcground_speed_multipler
	$ParallaxBackground.set_speed_multipler( player_multipler )
	time_reduciton += player_multipler * delta * 0.2
	
	for obstacle in get_children():
		if obstacle.is_in_group("obstalces"):
			obstacle.set_speed_multipler( player_multipler )

func _process(delta):
	update_time(delta)
	update_move_speed(delta)
	process_spawn()
	process_segment_end()
