extends Node2D

var main_node       = null
var world_is_paused = false
var pause_timer     = 0.0
var pause_end       = 0.0


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

func _process(delta):
	if pause_end <= pause_timer: 
		if world_is_paused: play_world()
	else: pause_timer += delta
