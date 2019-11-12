extends ParallaxBackground

export var SPEED = 30.0
export var SPEDD_MULTIPLER_1 = 1.0
export var SPEDD_MULTIPLER_2 = 2.0
export var SPEDD_MULTIPLER_3 = 3.0

func _ready(): pass

func move_background( node, speed ):
	node.motion_offset.x -= speed
	if node.motion_offset.x < -node.motion_mirroring.x: 
		node.motion_offset.x += node.motion_mirroring.x

func _process(delta): 
	move_background($Back1, SPEDD_MULTIPLER_1 * SPEED * delta)
	move_background($Back2, SPEDD_MULTIPLER_2 * SPEED * delta)
	move_background($Back3, SPEDD_MULTIPLER_3 * SPEED * delta)