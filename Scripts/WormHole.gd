extends KinematicBody2D

export var SPEED = 130

var speed_multipler  = 1
var fixed_y_pos      = 0
var points_jump_over = 50
var add_points       = true

func _ready():
	$AnimationPlayer.seek(rand_range(0, $AnimationPlayer.get_current_animation_length() ))

func adapt_speed( speed ):
	SPEED = speed

func grant_points():
	if !Utilities.player: return 
	if Utilities.player.position.x > position.x:
		get_parent().points += points_jump_over
		add_points = false
	
# warning-ignore:unused_argument
func _physics_process(delta):
	if Flow.world_is_paused: return
# warning-ignore:return_value_discarded
	move_and_slide( Vector2(-1, 0 ) * SPEED * speed_multipler )
	position.y = fixed_y_pos

	if add_points : grant_points()
	if position.x < -100 : call_deferred("queue_free")

func add_points_base_animation_moment( base ):
	if 2 <= base   and base  <= 3: get_parent().points += 300
	elif 1 <= base and base  <= 2: get_parent().points += 500
	elif 3 <= base and base  <= 4: get_parent().points += 500
	else: get_parent().points += 800

func _on_Area2D_body_entered(body):
	if body.is_in_group("missle"):
		var current_animation_position = $AnimationPlayer.current_animation_position
		add_points_base_animation_moment(current_animation_position)
		body.on_delete()
		$AnimationPlayer.call_deferred("queue_free")
		$Worm.call_deferred("queue_free")
