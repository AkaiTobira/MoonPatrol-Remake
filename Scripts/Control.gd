extends Control

var is_mine_first = true
var is_round_first = true
var is_worm_first = true

func _ready():
	$Distance/LifeLabel.text = "2"
	$Warnings/Checkpoint.text = ""
	$Warnings/ShortDistanceBar.visible = false
	$Distance/LifeLabel.visible = true
	$Distance/TextureRect.visible = true
	$Distance/XLabel.visible = true
	$Warnings/WarnBase.visible = true
	
	#get_segment_end_distance()
	
	
func update_timer(time_past):
	if time_past >= 0:
		$ScoreBoard/GTime.text = str(int(time_past))
	
func update_score(points):
	$ScoreBoard/ScoreResult.text = str(points)
	
func update_hi_score(hi_score):
	$ScoreBoard/HiScoreResult.text = str(hi_score)
	
func update_lives(lives_left):
	if int(lives_left) < 1:
		$Distance/LifeLabel.visible = false
		$Distance/TextureRect.visible = false
		$Distance/XLabel.visible = false
	else:
		$Distance/LifeLabel.text = str(lives_left)

func update_main_distance():
	pass

func update_drived_distance(drived_road):
	$Warnings/ShortDistanceBar.value = int( drived_road)

var to_travel = 3.625
var max_value = 1
	
func get_segment_end_distance():
	max_value = (LevelParser.get_letter_time() + to_travel) * Utilities.PIXOMETR
	$Warnings/ShortDistanceBar.value = 0
	$Warnings/ShortDistanceBar.max_value = max_value

func show_warning(obstacle):
	print(obstacle)
	
	match obstacle:
		"!Mine" :
			if is_mine_first == true:
				$Warnings/AnimationPlayer.play("mine")
				is_mine_first = false
		"!Round" :
			if is_round_first == true:
				$Warnings/AnimationPlayer.play("round")
				is_round_first = false
		"!Worm" :
			if is_worm_first == true:
				$Warnings/AnimationPlayer.play("worm")
				is_worm_first = false
	
func update_checkpoint(checkpoint):
	if checkpoint != null:
		$Warnings/WarnBase.visible = false
		$Warnings/Checkpoint.text = str(checkpoint)
		$Warnings/ShortDistanceBar.visible = true