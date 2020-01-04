extends Control

func _ready():
	$Distance/LifeLabel.text = "2"
	
func update_timer(time_past):
	$ScoreBoard/GTime.text = str(int(time_past))
	
func update_score(points):
	$ScoreBoard/ScoreResult.text = str(points)
	
func update_hi_score():
	pass
	
func update_lives(lives_left):
	$Distance/LifeLabel.text = str(lives_left)

func update_main_distance():
	pass

func update_segment_distance():
	pass
	
func show_warning(obstacle):
	print(obstacle)