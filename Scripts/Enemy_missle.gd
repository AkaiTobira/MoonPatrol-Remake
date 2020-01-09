extends Area2D

var direction = Vector2(0,1)
var squat_id  = -1
var SPEED     = 0

func _physics_process(delta):
	SPEED = min ( SPEED + 150*delta, 200 )
	position += direction * SPEED * delta

func on_delete(): 
	SquatController.missle_exploded(squat_id)
	call_deferred("queue_free")

func _on_Enemy_missle_body_entered(body):
	if body.is_in_group("missle"): 
		get_parent().points += 100
		body.on_delete()
		on_delete()
	if body.is_in_group("floor") : on_delete()

func _on_Enemy_missle_area_entered(area):
	if area.is_in_group("player") : 
		Utilities.player._on_Area2D_body_entered(self)
		on_delete()
		print( "hit" )
