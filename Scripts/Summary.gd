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
	texts["Reach"] = "Time to reach point " + '"' + reached_letter + '"'
	seconds = 0.2
	if timers["takes_time"] < timers["average_time"]: 
		states          = [ "Reach", "YTime", "ATime", "Ttime", "Bonus", "Record" ]
		aditonal_points = 1000
		LevelParser.save_top_record( timers["takes_time"] )
	else: states = [ "Reach", "YTime", "ATime", "Ttime", "NBonus" ]
	for child in get_children():
		if child.name == "Sprite": continue
		child.text = "" 

var letter_index = 0
var state_index  = 0
func _process(delta):
	timer += delta
	
	if timer > seconds:
		if not is_over and letter_index == len(texts[ states[state_index] ]): 
			if state_index == 1: $YourTime.text    = ": " + ("%03d" % timers["takes_time"])
			if state_index == 2: $AverageTime.text = ": " + ("%03d" % timers["average_time"])
			if state_index == 3: $TopRecord.text   = ": " + ("%03d" % timers["top_time"])
			if states[state_index] == "Bonus": $BonusPoint.text  = ": " + ("%04d" % LevelParser.get_additional_points() )
			state_index += 1
			letter_index = 0
		if state_index == len( states ) : 
			update_score()
			seconds = 0.5
			timer   = 0
			is_over = true
			
		if is_over: return
		var child = get_child( state_index + 1 )
		child.text = texts[ states[state_index] ].left(letter_index + 1)
		letter_index += 1
		timer = 0

func update_score():
	if timers["takes_time"] <= timers["average_time"]:
		timers["average_time"] -= 1
		aditonal_points += 100
		$YourTime.text    = ": " + ("%03d" % timers["takes_time"])
		$AverageTime.text = ": " + ("%03d" % timers["average_time"])
		$TopRecord.text   = ": " + ("%03d" % timers["top_time"])
		$BonusPoint.text  = ": " + ("%04d" % aditonal_points)
		
		if timers["takes_time"] == timers["average_time"]: seconds = 3
		return
	get_parent().points += aditonal_points
	Flow.play_world()
	hide()
	set_process(false)

