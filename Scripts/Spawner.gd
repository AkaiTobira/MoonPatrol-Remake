extends Node2D

var timer     = 0
var timer_max = 10

onready var hole = load( "res://Scenes/Rock.tscn" )

func _ready():
	get_child(0).SPEED = 0

func spawn():
	var instance = hole.instance() 
	instance.position = Vector2(position.x, 450)
	get_parent().add_child(instance)

func _process(delta):
	timer += delta
	if timer > timer_max:
		spawn()
		timer_max = randi()%12 + 5
		timer = 0