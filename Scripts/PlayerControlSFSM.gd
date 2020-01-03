extends Node

var stack = []
# warning-ignore:unused_class_variable
var move_speed = 0

func _ready(): 
	stack.push_front( Idle.new(stack) )

func _exit_tree(): #FOR GOD SAKE THIS GODOT SHOULD DO!!!
	while len(stack):
		stack[0].stack = null
		stack.pop_front()

func _process(delta):
	if Flow.world_is_paused: return
	while stack[0].is_over : stack.pop_front()
	stack[0].update(delta)
	stack[0].handle_input()
	
	print( "Process is active" )
	

class State:
# warning-ignore:unused_class_variable
	var is_over    = false
	var stack      = null

	func _init(s_stack): 
		stack      = s_stack

class MoveLeft extends State:

	func _init(s_stack).(s_stack): pass

	func update(delta):
		var move_speed = Utilities.player.MaxMoveSpeed
		Utilities.player.relative_x = max( -100, Utilities.player.relative_x - 1 * delta * move_speed )	

	func handle_input():
		if Flow.world_is_paused : return
		if !Input.is_action_pressed("ui_left") : is_over = true
		elif Input.is_action_just_pressed("ui_accept"): stack.push_front( Shoot.new(stack) )
		elif Input.is_action_pressed("ui_up")   : stack.push_front( JumpLeft.new(stack)  ) 
		
class MoveRight extends State:

	func _init(s_stack).(s_stack): pass
	
	func update(delta):
		var move_speed = Utilities.player.MaxMoveSpeed
		Utilities.player.relative_x = min( 100, Utilities.player.relative_x + 1 * delta * move_speed )	

	func handle_input():
		if Flow.world_is_paused : return
		if !Input.is_action_pressed("ui_right") : is_over = true
		elif Input.is_action_just_pressed("ui_accept"): stack.push_front( Shoot.new(stack) )
		elif Input.is_action_pressed("ui_up")   : stack.push_front( JumpRight.new(stack)) 

class JumpRight extends State:
	var gravity        = 0
	var target_hight  = 0 
	
	func _init(s_stack).(s_stack):
		target_hight = Utilities.player.position.y - 30 - (Utilities.player.MaxJump + (Utilities.player.relative_x * Utilities.player.MaxJump/200))
		Utilities.player.is_jumping = true
		Utilities.player.on_floor   = false
		Utilities.player.relative_y = target_hight
		gravity                  = Utilities.player.Gravity

	func update(delta ):
		var move_speed = Utilities.player.MaxMoveSpeed
		Utilities.player.relative_x = min( 100, Utilities.player.relative_x + 1 * delta * move_speed ) 
		if Utilities.player.position.y < target_hight :  Utilities.player.is_jumping = false
	#	if abs( Utilities.player.position.y - target_hight) < gravity*delta : Utilities.player.is_jumping = false
		if Utilities.player.on_floor: is_over = true 

	func handle_input():
		if Flow.world_is_paused : return
		if Input.is_action_just_pressed("ui_accept"): stack.push_front( Shoot.new(stack) )

class JumpLeft extends State:
	var gravity        = 0
	var target_hight  = 0 
	
	func _init(s_stack).(s_stack):
		target_hight = Utilities.player.position.y - 30 - (Utilities.player.MaxJump + (Utilities.player.relative_x * Utilities.player.MaxJump/200))
		Utilities.player.is_jumping = true
		Utilities.player.on_floor   = false
		Utilities.player.relative_y = target_hight
		gravity                  = Utilities.player.Gravity

	func update(delta):
		var move_speed = Utilities.player.MaxMoveSpeed
		Utilities.player.relative_x = max( -100, Utilities.player.relative_x - 1 * delta * move_speed ) 
		if Utilities.player.position.y < target_hight :  Utilities.player.is_jumping = false
	
	#	if abs( Utilities.player.position.y - target_hight) < gravity*delta : Utilities.player.is_jumping = false
		if Utilities.player.on_floor: is_over = true 

	func handle_input():
		if Flow.world_is_paused : return
		if Input.is_action_just_pressed("ui_accept"): stack.push_front( Shoot.new(stack) )

class Shoot extends State:

	func _init(s_stack).(s_stack): pass	

	func can_shoot_forward():
		return !Utilities.player.forward_missle

	func can_shoot_up():
		return Utilities.player.fire_up_missles < 3

# warning-ignore:unused_argument
	func update(delta):
		if can_shoot_forward()    : Utilities.player.shoot_forward()
		if can_shoot_up():
			Utilities.player.fire_up_missles += 1
			Utilities.player.shoot_up()
		is_over = true
		
	func handle_input(): pass

class JumpIdle extends State:
	var gravity        = 0
	var target_hight  = 0 
	
	func _init(s_stack).(s_stack):
		target_hight = Utilities.player.position.y - 30 - (Utilities.player.MaxJump + (Utilities.player.relative_x * Utilities.player.MaxJump/200))
		Utilities.player.is_jumping = true
		Utilities.player.on_floor   = false
		Utilities.player.relative_y = target_hight
		gravity                     = Utilities.player.Gravity

	func update(delta):
		var move_speed = Utilities.player.MaxMoveSpeed
		if Utilities.player.relative_x < 0   : Utilities.player.relative_x = min( 0, Utilities.player.relative_x + 1 * delta * move_speed )
		elif Utilities.player.relative_x > 0 : Utilities.player.relative_x = max( 0, Utilities.player.relative_x - 1 * delta * move_speed )
		if Utilities.player.position.y < target_hight :  Utilities.player.is_jumping = false
		
	#	if abs( Utilities.player.position.y - target_hight) < gravity*delta : Utilities.player.is_jumping = false
			
		if Utilities.player.on_floor: is_over = true 

	func handle_input():
		if Flow.world_is_paused : return
		if Input.is_action_just_pressed("ui_accept"): stack.push_front( Shoot.new(stack) )


class Idle extends State:

	func _init(s_stack).(s_stack): pass

	func update(delta):
		var move_speed = Utilities.player.MaxMoveSpeed
		if Utilities.player.relative_x < 0   : Utilities.player.relative_x = min( 0, Utilities.player.relative_x + 1 * delta * move_speed )
		elif Utilities.player.relative_x > 0 : Utilities.player.relative_x = max( 0, Utilities.player.relative_x - 1 * delta * move_speed )

	func handle_input():
		if Flow.world_is_paused : return
		if Input.is_action_just_pressed("ui_accept"): stack.push_front( Shoot.new(stack) )
		elif Input.is_action_pressed("ui_up")   : stack.push_front( JumpIdle.new(stack))
		elif Input.is_action_pressed("ui_right"): stack.push_front( MoveRight.new(stack) )
		elif Input.is_action_pressed("ui_left") : stack.push_front( MoveLeft.new(stack) )