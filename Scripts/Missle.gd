extends KinematicBody2D

var direction  = Vector2(0,0)
var SPEED      = 400
var life_range = 100

var lifed_range = 0

func _physics_process(delta):
	lifed_range += SPEED * delta
	if move_and_collide( direction * SPEED * delta ) or lifed_range > life_range:
		call_deferred("queue_free")
	