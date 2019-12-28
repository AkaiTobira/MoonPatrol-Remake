extends Control

func update_score():
	pass
	
func update_hi_score():
	pass
	
func update_lives():
	$Distance/LifeLabel.text = str( Utilities.player.lives )
	
func update_main_distance():
	pass

func update_segment_distance():
	pass
	
func show_warning(obstacle):
	if obstacle == true:
		$Warnings/ObstacleWarning.visible = true
		
		
func _process(delta):
	update_lives()