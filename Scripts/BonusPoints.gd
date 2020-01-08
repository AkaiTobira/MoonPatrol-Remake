extends Node2D

# warning-ignore:unused_class_variable
var t = Timer.new()
func show_bonus(bonus):
	$BonusLabel.visible = true
	$BonusLabel.text = "Squad Destroyed!!! \n Bonus: " + str(bonus)
	$AnimationPlayer.play("bonus")
#	t.set_wait_time(3)
#	$BonusLabel.visible = false