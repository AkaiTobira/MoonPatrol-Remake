extends Sprite

export var SPEED = 100

var speed_multipler = 1
var fixed_y_pos = 0

func set_speed_multipler( player_multipler ):
	speed_multipler = 1 + player_multipler
	
func set_letter(letter):
	$Label.text = letter

onready var player = get_node("/root/Root/Player")

var is_not_reached = true

func save_checkpoint():
	if !player: return 
	if player.position.x > position.x:
		get_parent().player_reached_next_letter()
		is_not_reached = false

# warning-ignore:unused_argument
func _process(delta):
	position = Vector2( position.x - 1 * SPEED * speed_multipler * delta, fixed_y_pos)
	if is_not_reached : save_checkpoint()
	if position.x < -100 : call_deferred("queue_free")