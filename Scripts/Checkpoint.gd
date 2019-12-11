extends Sprite

export var SPEED = 100

var is_not_reached  = true
var speed_multipler = 1
var fixed_y_pos     = 0

func adapt_speed( speed ):
	SPEED = speed

func set_letter(letter):
	$Label.text = letter

func save_checkpoint():
	if !Utilities.player: return 
	if Utilities.player.position.x > position.x:
		get_parent().next_checkpoint($Label.text)
		is_not_reached = false

func _process(delta):
	if Flow.world_is_paused: return
	position = Vector2( position.x - 1 * SPEED * speed_multipler* delta, fixed_y_pos)
	if is_not_reached : save_checkpoint()
	if position.x < -100 : call_deferred("queue_free")