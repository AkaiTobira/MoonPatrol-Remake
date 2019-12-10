extends Node

var stack = []
# warning-ignore:unused_class_variable
var move_speed = 0
var pause      = false 

func stop(): pause = true
func play(): pause = false

func _ready(): 
	stack.push_front( Idle.new(stack) )

func _exit_tree(): #FOR GOD SAKE THIS GODOT SHOULD DO!!!
	while len(stack):
		stack[0].stack = null
		stack.pop_front()

func _process(delta):
	if pause: return
	while stack[0].is_over : stack.pop_front()
	stack[0].update(delta)
	stack[0].handle_input()

class State:
# warning-ignore:unused_class_variable
	var is_over    = false
	var stack      = null

	func _init(s_stack): 
		stack      = s_stack

class MoveLeft extends State:

	func _init(s_stack).(s_stack): pass

	func update(delta):
		var move_speed = Common.player.MaxMoveSpeed
		Common.player.relative_x = max( -100, Common.player.relative_x - 1 * delta * move_speed )	

	func handle_input():
		if !Input.is_action_pressed("ui_left") : is_over = true
		elif Input.is_action_just_pressed("ui_accept"): stack.push_front( Shoot.new(stack) )
		elif Input.is_action_pressed("ui_up")   : stack.push_front( JumpLeft.new(stack)  ) 
		
class MoveRight extends State:

	func _init(s_stack).(s_stack): pass
	
	func update(delta):
		var move_speed = Common.player.MaxMoveSpeed
		Common.player.relative_x = min( 100, Common.player.relative_x + 1 * delta * move_speed )	

	func handle_input():
		if !Input.is_action_pressed("ui_right") : is_over = true
		elif Input.is_action_just_pressed("ui_accept"): stack.push_front( Shoot.new(stack) )
		elif Input.is_action_pressed("ui_up")   : stack.push_front( JumpRight.new(stack)) 

class JumpRight extends State:
	var gravity = 0
	
	func _init(s_stack).(s_stack):
		Common.player.force = Common.player.MaxJump + (Common.player.relative_x * Common.player.MaxJump/200)
		Common.player.on_floor   = false
		gravity             = Common.player.Gravity

	func update(delta ):
		var move_speed = Common.player.MaxMoveSpeed
		Common.player.relative_x = min( 100, Common.player.relative_x + 1 * delta * move_speed ) 
		Common.player.force     -= gravity * delta
		if Common.player.on_floor: is_over = true 

	func handle_input():
		if Input.is_action_just_pressed("ui_accept"): stack.push_front( Shoot.new(stack) )

#
class JumpLeft extends State:
	var gravity = 0
	
	func _init(s_stack).(s_stack):
		Common.player.force = Common.player.MaxJump + (Common.player.relative_x * Common.player.MaxJump/200)
		Common.player.on_floor   = false
		gravity             = Common.player.Gravity

	func update(delta):
		var move_speed = Common.player.MaxMoveSpeed
		Common.player.relative_x = max( -100, Common.player.relative_x - 1 * delta * move_speed ) 
		Common.player.force -= gravity * delta
		if Common.player.on_floor: is_over = true 

	func handle_input():
		if Input.is_action_just_pressed("ui_accept"): stack.push_front( Shoot.new(stack) )

class Shoot extends State:

	func _init(s_stack).(s_stack): pass	

	func can_shoot_forward():
		return !Common.player.forward_missle

	func can_shoot_up():
		return Common.player.fire_up_missles < 3

# warning-ignore:unused_argument
	func update(delta):
		if can_shoot_forward()    : Common.player.shoot_forward()
		if can_shoot_up():
			Common.player.fire_up_missles += 1
			Common.player.shoot_up()
		is_over = true
		
	func handle_input(): pass

class JumpIdle extends State:
	var gravity        = 0
	
	func _init(s_stack).(s_stack):
		Common.player.force = Common.player.MaxJump + (Common.player.relative_x * Common.player.MaxJump/200)
		Common.player.on_floor   = false
		gravity             = Common.player.Gravity

	func update(delta):
		var move_speed = Common.player.MaxMoveSpeed
		if Common.player.relative_x < 0   : Common.player.relative_x = min( 0, Common.player.relative_x + 1 * delta * move_speed )
		elif Common.player.relative_x > 0 : Common.player.relative_x = max( 0, Common.player.relative_x - 1 * delta * move_speed )
		Common.player.force -= gravity * delta
		if Common.player.on_floor: is_over = true 

	func handle_input():
		if Input.is_action_just_pressed("ui_accept"): stack.push_front( Shoot.new(stack) )


class Idle extends State:

	func _init(s_stack).(s_stack): pass

	func update(delta):
		var move_speed = Common.player.MaxMoveSpeed
		if Common.player.relative_x < 0   : Common.player.relative_x = min( 0, Common.player.relative_x + 1 * delta * move_speed )
		elif Common.player.relative_x > 0 : Common.player.relative_x = max( 0, Common.player.relative_x - 1 * delta * move_speed )

	func handle_input():
		if Input.is_action_just_pressed("ui_accept"): stack.push_front( Shoot.new(stack) )
		elif Input.is_action_pressed("ui_up")     : stack.push_front( JumpIdle.new(stack))
		elif Input.is_action_pressed("ui_right"): stack.push_front( MoveRight.new(stack) )
		elif Input.is_action_pressed("ui_left") : stack.push_front( MoveLeft.new(stack) )