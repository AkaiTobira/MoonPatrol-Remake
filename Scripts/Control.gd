extends Control

func _ready():
	$Distance/LifeLabel.text = "2"
	
func update_timer(time_past):
	if time_past >= 0:
		$ScoreBoard/GTime.text = str(int(time_past))
	
func update_score():
	$ScoreBoard/ScoreResult.text = str(get_parent().get_parent().points)
	
func update_hi_score():
	pass
	
func update_lives(lives_left):
	$Distance/LifeLabel.text = str(lives_left)

func update_main_distance():
	pass

func update_segment_distance():
	pass
	
func show_warning(obstacle):
	if obstacle == true:
		$Warnings/ObstacleWarning.visible = true

func update_segment_letter(checkpoint_letter):
	$Warnings/Checkpoint.text = checkpoint_letter
	