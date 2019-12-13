extends Node2D


var state = "Normal"

func _ready():
	state = "Rise"
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var should_fall = false

func start_fall():
	should_fall = true
	
func set_info( info ): pass
##	if not info: return
##	state       = info[0]
##	position    = info[1]
##	should_fall = info[2]
#
##	$StaticBody2D2.position = info[3][0]
#	$StaticBody2D3.position = info[3][1]
#	$StaticBody2D4.position = info[3][2]
#
#	$End_fall_mark.position = info[4][0]
#	$End_high_mark.position = info[4][1]
#	$End_rise_mark.position = info[4][2]
#
#	$ParallaxBackground/ParallaxLayer.motion_offset.x = info[5]

func get_info( ): pass
#	var s = [ $StaticBody2D2.position, $StaticBody2D3.position, $StaticBody2D4.position ]
#	var z = [ $End_fall_mark.position, $End_high_mark.position, $End_rise_mark.position ]
#
#	return [ state, position, should_fall, s, z , $ParallaxBackground/ParallaxLayer.motion_offset.x ] 

func move_everything(delta):
	var speed = get_parent().road_speed * delta
	position.x                   -= speed
	$StaticBody2D2.position.x    -= speed
	$StaticBody2D3.position.x    -= speed
	$StaticBody2D4.position.x    -= speed
	$ParallaxBackground.offset.x -= 2* speed
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
		
	#	print( $StaticBody2D4.position )
	#	reparent( self, $StaticBody2D4, $ParallaxBackground/ParallaxLayer )
	#	print( $ParallaxBackground/ParallaxLayer/StaticBody2D4.position )

func reparent(parent, child, to):
	parent.remove_child(child)
	to.add_child(child)
	child.set_owner(to)

func handle_high(delta):
	if state != "High" : return
	#print( $ParallaxBackground/ParallaxLayer/StaticBody2D4.position )
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
			#reparent( $ParallaxBackground/ParallaxLayer, $ParallaxBackground/ParallaxLayer/StaticBody2D4, self  )
	elif state == "preFall2":
		move_everything(delta)
		if ($End_high_mark.position.x + position.x) < 450 : state = "Fall"
	elif state == "Fall" :
		move_everything(delta)
		if ($End_fall_mark.position.x + position.x) < 450 : call_deferred( "queue_free" )



func _process(delta): 
	#print( state, should_fall )
	handle_rise(delta)
	handle_high(delta)
	handle_fall(delta)
