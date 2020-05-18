extends airState

const JUMP_AGAIN_MARGIN = 0.12 # seconds need to press jump this amout of time for it to input buffer
const COYOTE_TIME = 0.08 # time after leaving edge before you are not allowed to jump

var coyote_timer : float # here incase playeer walks off an edge
var jump_timer : float
var jump_again : bool # jump keypress bufered
var jump_count : int
var enter_velocity

func enter():
	enter_velocity = owner.velocity
	if 500 > abs(enter_velocity.x):
		enter_velocity.x = 500

	owner.play_anim("hover")
	owner.queue_anim("fall")
	coyote_timer = COYOTE_TIME
	jump_again = false


func update(delta):
	coyote_timer -= delta
	jump_timer -= delta

	owner.velocity.y = min( owner.TERM_VEL, owner.velocity.y + owner.GRAVITY * delta ) # dunnid delta here by right, move and slide deals with it

	var input_dir = get_input_direction()
	update_look_direction(input_dir)
	var dir = input_dir.x

	if dir:
		owner.velocity.x = clamp ((owner.velocity.x + dir*owner.AIR_ACCEL), -abs(enter_velocity.x), abs(enter_velocity.x))
	else:
		owner.velocity.x = lerp( owner.velocity.x, 0, owner.AIR_ACCEL * delta )

	owner.move_and_slide(owner.velocity, Vector2.UP)

	# jump input buffering
	if Input.is_action_just_pressed( "jump" ):
		jump_timer = JUMP_AGAIN_MARGIN
		jump_again = true
		if coyote_timer > 0 and not owner.has_jumped:  # when accidentally falling off edges
				emit_signal("finished", "jump")
				return

	# landing
	if owner.is_on_floor():
		owner.has_jumped = false
		owner.play_anim("land")
		if (jump_again and jump_timer >= 0):
			owner.get_node("states").states_stack.pop_front()
			emit_signal("finished", "jump")
		else:
			# land
			if owner.get_node("states").states_stack.size() == 1:
				emit_signal("finished", "idle")
			else:
				emit_signal("finished", "previous")
	.update(delta)
