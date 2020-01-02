extends Control

func _ready():
	$Distance/LifeLabel.text = "2"
	

func update_score():
	pass
	
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