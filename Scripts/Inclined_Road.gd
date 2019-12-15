extends Node2D


var state = "Normal"

func _ready():
	state = "Rise"

var should_fall = false

func start_fall():
	should_fall = true
	
func set_info( info ):
	if info == null : 
		get_parent().get_node("Back3/StaticBody2D").position.y = parent_collider_y
		queue_free()
		return

	if info[0] == "Rise" and state == "High" : 
		get_parent().get_node("Back3/StaticBody2D").position.y = parent_collider_y
		queue_free()

	if state == "Hight"  and info[1] == should_fall: should_fall = info[1]

func get_info( ): 
	return [ state, should_fall ]

func move_everything(delta):
	var speed = get_parent().road_speed * delta
	#position.x                   -= speed
	$StaticBody2D2.position.x    -= speed
	$StaticBody2D3.position.x    -= speed
	$StaticBody2D4.position.x    -= speed
	$ParallaxBackground.offset.x -= speed
	$End_rise_mark.position.x    -= speed
	$End_high_mark.position.x    -= speed
	$End_fall_mark.position.x    -= speed

func handle_rise(delta):
	if state != "Rise" : return
	move_everything(delta)
	if ($End_rise_mark.position.x + position.x) < 450 : 
		state = "High"
		parent_collider_y = get_parent().get_node("Back3/StaticBody2D").position.y
		get_parent().get_node("Back3/StaticBody2D").position.y = 10

func reparent(parent, child, to):
	parent.remove_child(child)
	to.add_child(child)
	child.set_owner(to)

func handle_high(delta):
	if state != "High" : return
	$ParallaxBackground/ParallaxLayer.motion_offset.x -= get_parent().road_speed * delta
	if $ParallaxBackground/ParallaxLayer.motion_offset.x < -$ParallaxBackground/ParallaxLayer.motion_mirroring.x: 
		$ParallaxBackground/ParallaxLayer.motion_offset.x += $ParallaxBackground/ParallaxLayer.motion_mirroring.x
	if should_fall: 
		state = "preFall1"

var parent_collider_y = 0

func handle_fall(delta):
	if state == "preFall1":
		$ParallaxBackground/ParallaxLayer.motion_offset.x -= get_parent().road_speed * delta
		if $ParallaxBackground/ParallaxLayer.motion_offset.x < -$ParallaxBackground/ParallaxLayer.motion_mirroring.x: 
			$ParallaxBackground/ParallaxLayer.motion_offset.x += $ParallaxBackground/ParallaxLayer.motion_mirroring.x
			reparent($ParallaxBackground/ParallaxLayer, $ParallaxBackground/ParallaxLayer/Sprite2, $ParallaxBackground )
			state = "preFall2"
			get_parent().get_node("Back3/StaticBody2D").position.y = parent_collider_y
	elif state == "preFall2":
		move_everything(delta)
		if ($End_high_mark.position.x + position.x) < 450 : state = "Fall"
	elif state == "Fall" :
		move_everything(delta)
		if ($End_fall_mark.position.x + position.x) < 450 : call_deferred( "queue_free" )

func _process(delta): 
	print( state, should_fall )
	handle_rise(delta)
	handle_high(delta)
	handle_fall(delta)
