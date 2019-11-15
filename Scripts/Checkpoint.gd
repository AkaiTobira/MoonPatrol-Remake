extends Sprite

export var SPEED = 100

var speed_multipler = 1
var fixed_y_pos = 0

func set_speed_multipler( player_multipler ):
	speed_multipler = 1 + player_multipler
	
func set_letter(letter):
	$Label.text = letter
	
# warning-ignore:unused_argument
func _process(delta):
	position = Vector2( position.x - 1 * SPEED * speed_multipler * delta, fixed_y_pos)
	if position.x < -100 : call_deferred("queue_free")