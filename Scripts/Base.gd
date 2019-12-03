extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var background_speed = 0
func _process(delta):
	var background = get_parent().get_node("ParallaxBackground")
	position.x = position.x - background.SPEDD_MULTIPLER_3 * background.player_speed * background.SPEED * delta
