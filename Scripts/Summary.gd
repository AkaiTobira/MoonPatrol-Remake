extends Node2D

var texts = { 
	"Reach"  : "Time to reach point ",
	"YTime"  : "Your time",
	"ATime"  : "Average time",
	"Ttime"  : "Top time",
	"Bonus"  : "Good Bonus Point",
	"NBonus" : "Sory no bonus for you",
	"Record" : "You have broken the record"
}

var reached_letter = ""
var timers         = {}
var is_over        = false

func _ready(): set_process(false)

func start_typing_sequences( letter, tims ):
	is_over        = false
	timers         = tims
	reached_letter = letter
	letter_index = 0
	state_index  = 0
	reset()
	show()
	set_process(true)

var timer   = 0.0
var seconds = 0.2
var aditonal_points = 0 

var states = [ "Reach", "YTime", "ATime", "Ttime", "Bonus", "Record", "NRecord" ]

func reset():
	texts["Reach"] = "Time to reach point " + '"' + str(char(reached_letter)) + '"'
	
	if timers["takes_time"] < timers["top_time"]: 
		states   = [ "Reach", "YTime", "ATime", "Ttime", "Bonus", "Record" ]
		Common.set_new_top_record( timers["takes_time"] )
	else: states = [ "Reach", "YTime", "ATime", "Ttime", "NBonus" ]
	for child in get_children():
		if child.name == "Sprite": continue
		child.text = "" 

var letter_index = 0
var state_index  = 0
func _process(delta):
	timer += delta
	
	if timer > seconds:
		if letter_index == len(texts[ states[state_index] ]): 
			if state_index == 1: $YourTime.text    = ": " + ("%03d" % timers["takes_time"])
			if state_index == 2: $AverageTime.text = ": " + ("%03d" % timers["average_time"])
			if state_index == 3: $TopRecord.text   = ": " + ("%03d" % timers["top_time"])
			if states[state_index] == "Bonus": $BonusPoint.text  = ": " + ("%04d" % aditonal_points )
			state_index += 1
			letter_index = 0
		if state_index == len( states ) : 
			get_parent().play_world()
			hide()
			set_process(false)
			is_over = true
			
		if is_over: return
		var child = get_child( state_index + 1 )
		child.text = texts[ states[state_index] ].left(letter_index + 1)
		letter_index += 1
		timer = 0
