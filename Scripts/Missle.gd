extends KinematicBody2D

var direction     = Vector2(0,0)
export var SPEED  = 400
var life_range    = 450
var lifed_range   = 0

func _physics_process(delta):
	lifed_range += SPEED * delta
	var output = move_and_collide( direction * SPEED * delta )
	if output or lifed_range > life_range: on_delete()

func on_delete(): 
	Utilities.player.fire_up_missles -= 1
	call_deferred("queue_free")