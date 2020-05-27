extends Camera2D
class_name ShakeCamera

var LOOK_AHEAD_FACTOR = 10  # DONT CHANGE HERE CHANGE BELOW # percentage of screen to shift for looking ahead when changing directions
const SHIFT_TRANS = Tween.TRANS_SINE # choose transition here
const SHIFT_EASE = Tween.EASE_IN_OUT
const SHIFT_DURATION = 10000.0 # ms
const SMOOTH_SPEED_FACTOR = .0001
# SHAKE
var _duration := 0.0
var _period_in_ms := 0.0
var _amplitude := 0.0
var _timer := 0.0
var _last_shook_timer := 0.0
var _previous_x := 0.0
var _previous_y := 0.0
var _last_offset := Vector2(0, 0)
var _shakedir := Vector2( 1, 1 )

var shake_offset := Vector2()
var pan_offset := Vector2()
var target_pan_offset := Vector2()
var pan_speed := 3.0

var slowmo_target = Vector2()
var slowmo_offset = Vector2()

var facing = 0
var smoothing_speed_goal = 0
var camera_state = 0
enum camera_states { DEFAULT = 0, HOOK = 1}

onready var prev_camera_pos = get_camera_position()
onready var tween = $ShiftTween # this caches a node no need to reload in downtimes between uses

# processes screenshake / pan
func _physics_process( delta ):
	camera_process(delta)

	if _timer != 0:
		_last_shook_timer = _last_shook_timer + delta
		while _last_shook_timer >= _period_in_ms:
			_last_shook_timer = _last_shook_timer - _period_in_ms
			var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
			# Noise calculation logic from http://jonny.morrill.me/blog/view/14
			var new_x = rand_range(-1.0, 1.0)
			var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
			var new_y = rand_range(-1.0, 1.0)
			var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
			_previous_x = new_x
			_previous_y = new_y
			# Track how much we've moved the offset, as opposed to other effects.
			var new_offset = Vector2(x_component, y_component)
			shake_offset -= _last_offset - new_offset
			_last_offset = new_offset
		# Reset the offset when we're done shaking.
		_timer = _timer - delta
		if _timer <= 0:
			_timer = 0
			shake_offset -= _last_offset
	else:
		shake_offset = shake_offset.linear_interpolate( Vector2.ZERO, delta )
	# pan camera
	pan_offset = pan_offset.linear_interpolate( target_pan_offset, pan_speed * delta )
	if abs( pan_offset.y ) < 0.5:
		pan_offset.y = 0

	slowmo_offset = lerp( slowmo_offset, slowmo_target, 10 * delta )

	if _timer != 0:
		if _shakedir == Vector2.ZERO:
			offset = shake_offset + pan_offset
		else:
			offset = shake_offset.length() * _shakedir + pan_offset
	else:
		offset = pan_offset
	offset += slowmo_offset

# CAMERA EFFECTS
func shake(duration, frequency, amplitude, shakedir = Vector2.ZERO ):
	# Initialize variables.
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = rand_range(-0.5, 0.5)
	_previous_y = rand_range(-0.5, 0.5)
	_shakedir = shakedir
	shake_offset -= _last_offset
	_last_offset = Vector2.ZERO

func pan_camera( pan : Vector2 ) -> void:
	target_pan_offset = pan
	pass

# GAME CAMERA
func camera_process(delta):
	_check_facing()
	prev_camera_pos = get_camera_position()
	smoothing_speed = lerp(smoothing_speed, smoothing_speed_goal, delta * SMOOTH_SPEED_FACTOR)

func _check_facing():
	var new_facing = sign(get_camera_position().x - prev_camera_pos.x) # +1 camera moves to the right else -1 if left else 0
	if new_facing != 0 && facing != new_facing:
		facing = new_facing
		var target_offset = get_viewport_rect().size.x * facing * LOOK_AHEAD_FACTOR
		position.x = target_offset
		# modify the self object propery position:x, from the current positino to the target and use the following parementers:
		tween.interpolate_property(self, "position:x", position.x, target_offset, SHIFT_DURATION, SHIFT_TRANS, SHIFT_EASE)
		tween.start()

func _on_player_camera_command(command, arg):
	print(command ,arg)
	camera_state = command

	var dist = (global_position - get_parent().global_position).length()
	match (camera_state):
		camera_states.DEFAULT:
			drag_margin_left = .11
			drag_margin_right = .11
			drag_margin_top = 0.4
			drag_margin_bottom = .2
			drag_margin_v_enabled = not  arg
			drag_margin_h_enabled = true
#			zoom = Vector2(1.5,1.5)
			smoothing_speed_goal = .5
			LOOK_AHEAD_FACTOR = .2
		camera_states.HOOK:
			drag_margin_left = .32
			drag_margin_right = .32
			drag_margin_top = 0.4
			drag_margin_bottom = .2
			drag_margin_v_enabled = true
			drag_margin_h_enabled = true
#			zoom = Vector2(1.5,1.5)
			smoothing_speed_goal = 2.5# 480x320 use 2.5 384 use 2.7
			LOOK_AHEAD_FACTOR = .25

func _on_player_shake(dur, freq, amp, dir):
	shake(dur, freq, amp, dir)

func _on_Chain_shake(dur, freq, amp, dir):
	shake(dur, freq, amp, dir)
