extends Node2D

var timer     = 0
var timer_max = 4

onready var rock = load( "res://Scenes/Rock.tscn" )

func _ready():
	get_child(0).SPEED = 0

func spawn():
	var instance = rock.instance() 
	instance.fixed_y_pos = position.y
	instance.position = position
	get_parent().add_child(instance)

func _process(delta):
#	timer += delta
	if timer > timer_max:
		spawn()
		timer_max = randi()%7 + 5
		timer = 0
