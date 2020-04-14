extends Node2D

var state             = "Normal"
var should_fall       = false
var parent_collider_y = 0

func _ready():
	parent_collider_y = get_parent().get_node("Back3/StaticBody2D").position.y
	state = "Rise"

func start_fall():
	should_fall = true
	
func set_info( info ):
	if info == null : 
		var straight_road = get_parent()
		if straight_road : straight_road.get_node("Back3/StaticBody2D").position.y = parent_collider_y
		queue_free()
		return

	if state != "High" :
		var node = get_parent().get_node("Back3/StaticBody2D")
		if node: node.position.y = parent_collider_y

	if info[0] == "Rise" and state == "High" : 
		get_parent().get_node("Back3/StaticBody2D").position.y = parent_collider_y
		state = "Rise"
	else: state = info[0]

	should_fall                                     = info[1]
	$Colliders.position.x                           = info[2]
	$ParallaxBackground.offset.x                    = info[3]
	$ParallaxBackground/ParallaxLayer.motion_offset = info[4]

func set_sprites( straight, left, right ):
	$ParallaxBackground/Sprite.texture        = left
	$ParallaxBackground/Sprite5.texture       = left
	$ParallaxBackground/Sprite3.texture       = right
	$ParallaxBackground/ParallaxLayer/Sprite2.texture = straight

func get_info( ): 
	var road_motion = $ParallaxBackground/ParallaxLayer.motion_offset
	var reducer = 250
	if state == "High": reducer = 0
	return [ state, should_fall, $Colliders.position.x + reducer, $ParallaxBackground.offset.x + reducer,  road_motion ]

func move_everything(delta):
	var speed = get_parent().road_speed * delta
	$Colliders.position.x        -= speed
#	$Colliders.move_colliders(speed)
	$ParallaxBackground.offset.x -= speed

func handle_rise(delta):
	if state != "Rise" : return
	move_everything(delta)
	if ($End_rise_mark.position.x + $ParallaxBackground.offset.x) < 450 : 
		state = "High"
		get_parent().get_node("Back3/StaticBody2D").position.y = 121

func reparent(parent, child, to):
	if not parent or not child or not to : return  
	parent.remove_child(child)
	to.add_child(child)
	child.set_owner(to)

func handle_high(delta):
	if state != "High" : return
	$ParallaxBackground/ParallaxLayer.motion_offset.x -= get_parent().road_speed * delta
	if $ParallaxBackground/ParallaxLayer.motion_offset.x < -$ParallaxBackground/ParallaxLayer.motion_mirroring.x: 
		$ParallaxBackground/ParallaxLayer.motion_offset.x += $ParallaxBackground/ParallaxLayer.motion_mirroring.x
	if should_fall:  state = "preFall1"

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
		if ($End_high_mark.position.x  + $ParallaxBackground.offset.x) < 450 : state = "Fall"
	elif state == "Fall" :
		move_everything(delta)
		if ($End_fall_mark.position.x  + $ParallaxBackground.offset.x) < 450 : call_deferred( "queue_free" )

func _process(delta): 
	if Flow.world_is_paused : return
	handle_rise(delta)
	handle_high(delta)
	handle_fall(delta)
	set_spawners_height()

func set_spawners_height():
	var is_low  = ("Fall" == state or state == "Rise")
	Flow.is_high          = not is_low
	Flow.hight_difference = parent_collider_y - get_parent().get_node("Back3/StaticBody2D").position.y
