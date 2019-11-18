extends KinematicBody2D

export var SPEED = 100

var points          = 50
var add_points      = true
var pause           = false

var speed_multipler = 1
var fixed_y_pos = 0

onready var player = get_node("/root/Root/Player")

func grant_points():
	if !player: return 
	if player.position.x > position.x:
		get_parent().points += points
		add_points = false


func play() : pause = false
func stop(): pause = true

func set_speed_multipler( player_multipler ):
	speed_multipler = 1 + player_multipler
	
# warning-ignore:unused_argument
func _physics_process(delta):
	if pause: return 
# warning-ignore:return_value_discarded
	move_and_slide( Vector2(-1, 0 ) * SPEED * speed_multipler )
	position.y = fixed_y_pos
	
	if add_points : grant_points()
	if position.x < -100 : call_deferred("queue_free")