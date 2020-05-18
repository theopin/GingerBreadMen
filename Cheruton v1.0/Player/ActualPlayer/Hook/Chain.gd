extends Node2D

const SPEED_TIP = 67
const HOOK_TIMER = .33 # how long to shoot out hook more means perfeformance hits to draw

var direction := Vector2(0,0)	# The direction in which the chain was shot

var chain_in_air
var hooked
var start_reel = false
onready var hook_timer = -1 # time before hook dissapears
var player_pos

onready var  link  = $link
onready var tip = $tip

signal hooked(tip_pos)

# com - command, 0 -start hook, 1 -release
func _on_player_hook_command(com, dir, player_pos):
	if com == 0: #START
		direction = dir.normalized() # incase forgot to
		chain_in_air = true
		tip.global_position = player_pos
		hook_timer = HOOK_TIMER
		$link.start()
	else: # END
		start_reel()

func start_reel():
	chain_in_air = false
	hooked = false
	start_reel = true

func _physics_process(delta: float) -> void:
	if not chain_in_air and not hooked and start_reel:
		direction = player_pos - tip.global_position
		tip.move_and_collide(direction.normalized() * SPEED_TIP * 1.3) # faster real
		if (link.global_position - player_pos).length() < 100:
			self.visible = false
	else:
		hook_timer -= delta
		self.visible = chain_in_air or hooked or (hook_timer>0)
		if not self.visible:
			return

		if hook_timer < 0 and not hooked:
			start_reel()

		if chain_in_air:
			var col = tip.move_and_collide(direction * SPEED_TIP)
			if col : #COLLISION
				var angle = tip.global_position.angle_to_point(player_pos)
				if  angle< deg2rad(-30)  and angle > deg2rad(-150) and col.normal.x == 0:
					hooked = true
					chain_in_air = false
					emit_signal("hooked", tip.global_position)
				else:
					start_reel()

	# drawing new rope link
	player_pos = DataResource.dict_player.player_pos
	link.c = max((player_pos - tip.global_position).length(),1)
	link.rotation = player_pos.angle_to_point(tip.global_position)
	link.global_position = tip.global_position

	tip.rotation = player_pos.angle_to_point(tip.global_position)
