extends Sprite

export var SPEED = 100

var is_not_reached  = true
var speed_multipler = 1
var fixed_y_pos     = 0

func set_speed_multipler( player_multipler ):
	speed_multipler = 1 + player_multipler

func set_letter(letter):
	$Label.text = letter

func save_checkpoint():
	if !Common.player: return 
	if Common.player.position.x > position.x:
		get_parent().player_reached_next_letter()
		is_not_reached = false

func _process(delta):
	get_parent().get_node("Sprite2").position = position + Vector2(0, -50 )
	position = Vector2( position.x - 1 * SPEED * speed_multipler* delta, fixed_y_pos)
	if is_not_reached : save_checkpoint()
	if position.x < -100 : call_deferred("queue_free")