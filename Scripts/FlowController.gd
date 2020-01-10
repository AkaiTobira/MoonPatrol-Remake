extends Node2D

var main_node       = null
var world_is_paused = false
var pause_timer     = 0.0
var pause_end       = 0.0

var is_high          = false
var hight_difference = 0

# warning-ignore:unused_class_variable
var high_score = 0

func play_intro_objects():
	if main_node.get_node("GUI/Welcomer").visible: main_node.get_node("GUI/Welcomer").visible = false
	if main_node.get_node("Base") : main_node.get_node("Base").play() 

func play_world():
	world_is_paused = false
	Utilities.player.play()

func pause_world( lenght_of_pause ):
	pause_end   = lenght_of_pause
	pause_timer = 0 
	world_is_paused = true
	Utilities.player.stop()

func clean_scene():
	SquatController.clear()
	for obstacle in main_node.get_children():
		if obstacle.is_in_group("enemy_missle"):
			obstacle.call_deferred( "queue_free" )
		if obstacle.is_in_group("obstalces"):
			obstacle.call_deferred( "queue_free" )
	Utilities.player.reset()

func adapt_height( instance ):
	if is_high: 
		instance.position.y  -= hight_difference
		instance.fixed_y_pos -= hight_difference

var is_over = false
func exit_to_intro( lenght_of_pause ):
	is_over = true
	SquatController.clear()
	pause_world( lenght_of_pause )

func reload_game():
	is_over = false
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/Intro.tscn")

var background_speed = 0
func freeze_screen():
	pause_world( 10000 )
	Utilities.player.block_player_animations()
	background_speed = main_node.get_node( "ParallaxBackground" ).SPEED 
	main_node.get_node( "ParallaxBackground" ).SPEED = 0

func unfreeze_screen():
	play_world()
	Utilities.player.play_player_animations()
	main_node.get_node( "ParallaxBackground" ).SPEED = background_speed
	play_BGM_music()

func stop_BGM_music():
	main_node.get_node("BGM").stop()
	
func play_BGM_music():
	main_node.get_node("BGM").play()

func show_congratulation():
	main_node.get_node("GUI/Welcomer").visible = true
	main_node.get_node("GUI/Welcomer").text    = "Congratulations!"

func play_end_game_music():
	Utilities.player.play_end_game_music()

func play_checkpoint_music():
	Utilities.player.play_checkpoint_music()

var saved_record = {
	"letter" : 0,
	"avg"    : 0,
	"top"    : 0,
	"time"   : 0
	}

func save_record_data( letter, avg, top ):
	saved_record["letter"] = letter
	saved_record["avg"]    = avg
	saved_record["top"]    = top
	saved_record["time"]   = main_node.timer_summary

func summarize( ):
	main_node.get_node("GUI/Welcomer").visible = false
	stop_BGM_music()
	pause_world( 100000 )
	main_node.get_node("Summary/V").start_typing_sequences( saved_record["letter"] , 
	   { "takes_time"   : saved_record["time"],
		 "top_time"     : saved_record["top"],
		 "average_time" : saved_record["avg"] } 
		)
	main_node.timer_summary = 0
	clean_scene()

func _process(delta):
	if pause_end <= pause_timer: 
		if world_is_paused: play_world()
		if is_over : reload_game()
	else: pause_timer += delta
