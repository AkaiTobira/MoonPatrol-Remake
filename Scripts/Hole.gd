extends KinematicBody2D

export var SPEED = 100

func _physics_process(delta):
	move_and_slide( Vector2(-1, 0 ) * SPEED )