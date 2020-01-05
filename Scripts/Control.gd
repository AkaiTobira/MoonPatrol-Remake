extends Control

func _ready():
	$Distance/LifeLabel.text = "2"
	$Warnings/Checkpoint.text = ""
	$Warnings/ShortDistanceBar.visible = false
	
	
func update_timer(time_past):
	$ScoreBoard/GTime.text = str(int(time_past))
	
func update_score(points):
	$ScoreBoard/ScoreResult.text = str(points)
	
func update_hi_score(hi_score):
	$ScoreBoard/HiScoreResult.text = str(hi_score)
	
func update_lives(lives_left):
	$Distance/LifeLabel.text = str(lives_left)

func update_main_distance():
	pass

func update_segment_distance():
	pass
	
func show_warning(obstacle):
	print(obstacle)
	match obstacle:
		"!Mine" :
#			$Warnings/Checkpoint.visible = false
#			$Warnings/ShortDistanceBar.visible = false 
			$Warnings/AnimationPlayer.play("mine")

		"!Round" :
#			$Warnings/Checkpoint.visible = false
#			$Warnings/ShortDistanceBar.visible = false  
			$Warnings/AnimationPlayer.play("round")

		"!Worm" :
#			$Warnings/Checkpoint.visible = false
#			$Warnings/ShortDistanceBar.visible = false  
			$Warnings/AnimationPlayer.play("worm")
	
	
func update_checkpoint(checkpoint):
	if checkpoint != null:
		$Warnings/Checkpoint.text = str(checkpoint)
		$Warnings/ShortDistanceBar.visible = true