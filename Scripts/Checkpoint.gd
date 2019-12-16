extends CanvasLayer

export var SPEED = 100

var is_not_reached  = true
var speed_multipler = 1
var fixed_y_pos     = 0

func adapt_speed( speed ):
	SPEED = speed

func set_letter(letter):
	$Sprite/Label.text = letter

func save_checkpoint():
	if !Utilities.player: return 
#print( $Sprite.position, offset, Utilities.player.position.x )
	if Utilities.player.position.x > offset.x:
		get_parent().next_checkpoint($Sprite/Label.text)
		is_not_reached = false

func _process(delta):
	if Flow.world_is_paused: return

	offset = Vector2( offset.x - 1 * SPEED * delta, offset.y)
	if is_not_reached : save_checkpoint()
	if offset.x < -100 : call_deferred("queue_free")