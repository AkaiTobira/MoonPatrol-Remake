extends RichTextLabel


var timer      = 0.0
var timer_over = 2.0

func _ready():
	pass # Replace with function body.

func _process(delta):
	timer += delta
	if timer < 2:
		rect_scale = Vector2(1,1) * timer 

func _on_Welcomer_visibility_changed():
	if visible: 
		timer = 0
		rect_scale = Vector2(1,1)
		set_process( true )
	else: set_process( false )
