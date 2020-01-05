extends ParallaxBackground

export var SPEED             = 60.0
export var SPEDD_MULTIPLER_0 = 0.25
export var SPEDD_MULTIPLER_1 = 1.0
export var SPEDD_MULTIPLER_2 = 2.0
export var SPEDD_MULTIPLER_3 = 4.0

var player_speed = 1

func set_speed_multipler( multipler ):
	player_speed = 1 + multipler
	road_speed   =  SPEDD_MULTIPLER_3 * player_speed * SPEED

func move_background( node, speed ):
	node.motion_offset.x -= speed
	if node.motion_offset.x < -node.motion_mirroring.x: 
		node.motion_offset.x += node.motion_mirroring.x

var textures = {
	"Background_1" : preload("res://Textures/Placeholders_old/Background_fill.png" ),
	"Background_2" : preload("res://Textures/Placeholders_old/Background_fill2.png" )
}

func handle_keyword(keyword):
	if !has_node( "Back4" ) and keyword[1] == "R": 
		add_child( Utilities.get_instance( "IRoad" ) )
	elif keyword[1] == "F":
		if has_node( "Back4" ): $Back4.start_fall()

func load_bakcground_fill( b_name ):
	$Back2/Sprite.texture = textures[b_name]

func get_backgoround_info():
	return [ $Back1.motion_offset.x, $Back2.motion_offset.x, $Back3.motion_offset.x, $Back4.get_info() if has_node( "Back4" ) else null  ]

func set_backgoround_info( info ):	
	$Back1.motion_offset.x = info[0]
	$Back2.motion_offset.x = info[1]
	$Back3.motion_offset.x = info[2]
	if not has_node("Back4") : 
		var road = Utilities.get_instance( "IRoad" )
		call_deferred( "add_child", road )
		road.set_info(info[3])
	else: $Back4.set_info(info[3])

var road_speed =  SPEDD_MULTIPLER_3 * player_speed * SPEED

func _process(delta): 
	if Flow.world_is_paused: return 
	road_speed =  SPEDD_MULTIPLER_3 * player_speed * SPEED
	move_background($Back5, SPEDD_MULTIPLER_0 * player_speed * SPEED * delta)
	move_background($Back1, SPEDD_MULTIPLER_1 * player_speed * SPEED * delta)
	move_background($Back2, SPEDD_MULTIPLER_2 * player_speed * SPEED * delta)
	move_background($Back3, SPEDD_MULTIPLER_3 * player_speed * SPEED * delta)
	
func _physics_process(delta):
	if Flow.world_is_paused: return
	$Back3/StaticBody2D.position.x = $Back3/StaticBody2D.position.x - (road_speed * delta)
	if $Back3/StaticBody2D.position.x < 646.09-1000 : $Back3/StaticBody2D.position.x = 646.09