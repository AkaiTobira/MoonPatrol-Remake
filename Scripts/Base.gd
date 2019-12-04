extends Sprite

var pause = true

func stop(): pause = true
func play(): pause = false

func _process(delta):
	if pause: return
	var background = get_parent().get_node("ParallaxBackground")
	get_parent().get_node("Player").stop()
	if position.x > 200:
		position.x = position.x - background.SPEDD_MULTIPLER_3 * background.player_speed * background.SPEED * delta
	else:
		get_parent().get_node("Player").play()
		call_deferred( "queu_free" )