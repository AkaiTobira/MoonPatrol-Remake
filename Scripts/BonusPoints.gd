extends Node2D

# warning-ignore:unused_class_variable
var t = Timer.new()
func show_bonus(bonus):
	if bonus > 0:
		$BonusLabel.visible = true
		$BonusLabel.text = "Squad Destroyed!!! \n Bonus: " + str(bonus)
		$AnimationPlayer.play("bonus")