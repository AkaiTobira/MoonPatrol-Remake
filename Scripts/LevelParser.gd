extends Node

# warning-ignore:unused_class_variable
var high_score = 0

func load_json():
	load_structure("LevelStructure1", 0 )
	load_structure("LevelStructure2", 1 )
	load_structure("LevelStructure3", 2 )
	load_structure("LevelStructure4", 3 )
	load_structure("LevelStructure5", 4 )
	load_structure("LevelStructure6", 5 )

func _ready():
	load_json()
	reset()

var json_levels = {}
var records  = { 
				0 : { "top": 0, "avg":0 },
				2 : { "top": 0, "avg":0 },
				3 : { "top": 0, "avg":0 },
				4 : { "top": 0, "avg":0 },
				5 : { "top": 0, "avg":0 },
				1 : { "top": 0, "avg":0 },
				6 : { "top": 0, "avg":0 }
}

var current_active_index  = -1
var current_active_letter = ""
var max_segments          = 6
var level_structure = {}

func load_structure(file_name, segment_index):
	var file = File.new()
	file.open("res://Resouces/" + file_name + ".json", file.READ)
	json_levels[segment_index] = parse_json(file.get_as_text())
	file.close()
	assert( json_levels[segment_index] != null )
	generate_level_segment_orded( segment_index )

func generate_level_segment_orded( segment_index ):
	randomize()
	level_structure[segment_index] = {}
	for letter in json_levels[segment_index]["level_structure"].keys():
		var temp = json_levels[segment_index]["level_structure"][letter]
		level_structure[segment_index][letter] = str(randi()%len(temp.keys())) 

func get_active_spawn_times():
	var selected_variant = level_structure[current_active_index][current_active_letter]
	return json_levels[current_active_index]["level_structure"][current_active_letter][selected_variant].duplicate(true)

func get_letter_time():
    var sel = get_active_spawn_times()
    for key in sel.keys():
        if sel[key][0] == "@" : 
            return float(key)

func get_background_info():
	return json_levels[current_active_index]["background"]

func reset():
	current_active_index = 0

	current_active_letter = json_levels[current_active_index]["start_segment"]

func on_json_change( letter ):
	Flow.stop_BGM_music()
	if current_active_index == 5: 
		Flow.show_congratulation()
		Flow.play_end_game_music()
	else: Flow.play_checkpoint_music()
	Flow.freeze_screen()
	
	Flow.save_record_data(  letter, 
							json_levels[current_active_index]["avr_time"],
							get_top_record() )

func reached_next_letter( letter ):
	if json_levels[current_active_index]["fixed_segment"] : return
	if json_levels[current_active_index]["end_segment"] == letter:
		reached_next_segment( current_active_letter )
		on_json_change( letter )
		return
	current_active_letter = letter
	get_tree().call_group("Control", "update_checkpoint", current_active_letter)

func get_additional_point(): return json_levels[current_active_index]["additional_points"]

func get_top_record():
	if not records[current_active_index]["top"]: records[current_active_index]["top"] = json_levels[current_active_index]["avr_time"]
	return records[current_active_index]["top"]

func change_active_segment( segment_index ):
	current_active_index  = segment_index
	current_active_letter = json_levels[current_active_index]["start_segment"]
	return true

func reached_next_segment( backup_letter ):
	if max_segments > current_active_index + 1 : 
		current_active_index += 1
		current_active_letter = json_levels[current_active_index]["start_segment"]
	else: current_active_letter = backup_letter
 
func save_top_record( new_time ):
	if records[ current_active_index ]["top"] < new_time :  records[ current_active_index ]["top"] = new_time
