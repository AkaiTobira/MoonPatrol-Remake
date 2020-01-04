extends Node2D

var main_node       = null
var world_is_paused = false
var pause_timer     = 0.0
var pause_end       = 0.0

var is_high          = false
var hight_difference = 0

var high_score = 0

func play_intro_objects():
	if main_node.get_node("UI/Welcomer").visible: main_node.get_node("UI/Welcomer").visible = false
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

func summarize( letter, avg_time, top_time ):
	pause_world( 100000 )
	main_node.get_node("Summary/V").start_typing_sequences( letter , { "takes_time"   : main_node.timer_summary,
																	 "top_time"     : top_time,
																	 "average_time" : avg_time } )
	main_node.timer_summary = 0
	clean_scene()

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
	get_tree().change_scene("res://Scenes/Intro.tscn")

func _process(delta):
	if pause_end <= pause_timer: 
		if world_is_paused: play_world()
		if is_over : reload_game()
	else: pause_timer += delta
