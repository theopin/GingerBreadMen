extends KinematicBody2D

# only put consts used by multiple states, no need to get owner each time
const GRAVITY = 2400
const TERM_VEL = 1000 # Terminal velocity when falling/ jumping straight up
const AIR_ACCEL = 28.5  # increase in this >> increase in stearing power in air
var velocity = Vector2()

var tip_pos = Vector2()
var previous_position
var hook_dir = Vector2()
var has_jumped = false
var on_floor = false setget signal_on_floor
var hooked

onready var animation_player = $AnimationPlayer

signal state_changed
signal hook_command
signal camera_command

var look_direction = Vector2(1, 0) setget set_look_direction

func take_damage(attacker, amount, effect=null):
	if self.is_a_parent_of(attacker):
		return
	$States/Stagger.knockback_direction = (attacker.global_position - global_position).normalized()
	$Health.take_damage(amount, effect)

func set_dead(value): # non zero means dead
	set_process_input(not value)
	set_physics_process(not value)
	$CollisionPolygon2D.disabled = value

func set_look_direction(value): # vector
	look_direction = value

func _on_states_state_changed(states_stack):
	emit_signal("state_changed", states_stack)

func signal_on_floor(grounded):
	on_floor = grounded
	emit_signal("camera_command", 0, on_floor)
	pass

func _physics_process(delta):
	previous_position = global_position # parent happens before children, so the current position is t
	DataResource.dict_player.player_pos = global_position # this is previous, need to goto actual state physics to get current

func play_anim(string):
	if animation_player:
		animation_player.play(string)
func queue_anim(string):
	if animation_player:
		animation_player.queue(string
		)
func start_hook():
	emit_signal("hook_command",0, hook_dir,global_position)

func _on_Chain_hooked(tip_p):
	hooked = 1
	tip_pos = tip_p
	$states._change_state("hook")

func chain_release():
	emit_signal("hook_command", 1,Vector2(),Vector2())

func move():
	move_and_slide(velocity, Vector2.UP)
