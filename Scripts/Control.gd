extends Control

var sum_of_segments = 0

func _ready():
	$Distance/LifeLabel.text      = "2"
	$Warnings/Checkpoint.text     = ""
	$Distance/LifeLabel.visible   = true
	$Distance/TextureRect.visible = true
	$Distance/XLabel.visible      = true
	$Warnings/WarnBase.visible    = true

func update_timer(time_past):
	$ScoreBoard/GTime.text = str( max (0, int(time_past)))

func update_score(points):
	$ScoreBoard/ScoreResult.text = ("%07d" % points)

func update_hi_score(hi_score):
	$ScoreBoard/HiScoreResult.text = ("%07d" % hi_score)

func update_lives(lives_left):
	if int(lives_left) < 1:
		$Distance/LifeLabel.visible   = false
		$Distance/TextureRect.visible = false
		$Distance/XLabel.visible      = false
	else:
		$Distance/LifeLabel.text      = str(lives_left)


func update_drived_distance(drived_road):
	$Warnings/ShortDistanceBar.value = int(drived_road)
	$Distance/DistanceBar.value      = sum_of_segments + drived_road
	
var to_travel = 3.625
func get_segment_end_distance():
	var max_value = (LevelParser.get_letter_time() + to_travel) * Utilities.PIXOMETR
	$Warnings/ShortDistanceBar.max_value = max_value
	sum_of_segments += $Warnings/ShortDistanceBar.value
	reset_distance_bar()
	
func update_main_distance():
	pass	

var NUMBER_OF_LETTERS = 25
func get_end_of_main_distance():
	var end_of_distance = (LevelParser.get_whole_distance() + NUMBER_OF_LETTERS * to_travel) * Utilities.PIXOMETR
	$Distance/DistanceBar.max_value = end_of_distance
	
func reset_distance_bar():
	$Warnings/ShortDistanceBar.value = 0

func show_warning(obstacle):
	match obstacle:
		"!Mine" :
			if $Warnings/AnimationPlayer.current_animation != "mine":
				$Warnings/AnimationPlayer.play("mine")
		"!Round" :
			if $Warnings/AnimationPlayer.current_animation != "round":
				$Warnings/AnimationPlayer.play("round")
		"!Worm" :
			if $Warnings/AnimationPlayer.current_animation != ("worm"):
				$Warnings/AnimationPlayer.play("worm")
		"!Bomber":
			if $Warnings/AnimationPlayer.current_animation != ("bomber"):
				$Warnings/AnimationPlayer.play("bomber")
				
func update_checkpoint(checkpoint):
	if checkpoint != null:
		$Warnings/WarnBase.visible = false
		$Warnings/Checkpoint.text = str(checkpoint)
		$Warnings/ShortDistanceBar.visible = true