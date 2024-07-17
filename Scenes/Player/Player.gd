extends RigidBody2D
class_name Player

const WALK_ACCEL = 1000.0
const WALK_DEACCEL = 1000.0
const WALK_MAX_VELOCITY = 200.0
const AIR_ACCEL = 325.0
const AIR_DEACCEL = 325.0
const JUMP_VELOCITY = 455.0
const STOP_JUMP_FORCE = 525.0
const MAX_SHOOT_POSE_TIME = .3
const MAX_FLOOR_AIRBORNE_TIME = .15
const BALANCE_EQUAL = .5

var siding_left = false
var anim = ""
var jumping = false
var stopping_jump = false
var shooting = false
var is_flipping = false

var floor_h_velocity: float = 0.0

var airborne_time: float = 1e20
var shoot_time: float = 1e20

@onready var visual = $VisualPlayer as Node2D
@onready var ray_cast = $RayCast2D as RayCast2D
@onready var animation_player = $AnimationPlayer as AnimationPlayer

@onready var weapon_component: WeaponComponent = $WeaponComponent

func _integrate_forces(state) -> void:
	if Input.is_action_just_pressed("spawn"):
		var rigid = load("res://RigidBody2D.tscn").instantiate()
		get_parent().add_child(rigid)
		rigid.global_position = get_global_mouse_position()
#	var rotation_radians = deg2rad(rotation_degrees)
#	var new_rotation = clamp(rotation_radians, -.8, .8)
#	var new_transform = Transform2D(new_rotation, position)
	$PinJoint2D.disable_collision
	var velocity = state.get_linear_velocity()
	var step = state.get_step()
	var current_angular_velocity: float
	
	var balance: float = state.get_angular_velocity()
	
	var new_anim = anim
	var new_siding_left = siding_left

	# Get player input.
	var move_left = Input.is_action_pressed("ui_left")
	var move_right = Input.is_action_pressed("ui_right")
	var jump = Input.is_action_pressed("jump")
	var f_interact = Input.is_action_just_pressed("ui_end")
	
	# Deapply prev floor velocity.
	velocity.x -= floor_h_velocity
	floor_h_velocity = 0.0

	# Find the floor (a contact with upwards facing collision normal).
	var found_floor = false
	var floor_index = -1

	for contact_index in state.get_contact_count():
		var collision_normal = state.get_contact_local_normal(contact_index)
		
		if collision_normal.dot(Vector2(0, -1)) > .6:
			found_floor = true
			floor_index = contact_index

	# A good idea when implementing characters of all kinds,
	# compensates for physics imprecision, as well as human reaction delay.

	if found_floor:
		airborne_time = 0.0
	else:
		airborne_time += step # Time it spent in the air.

	var on_floor := airborne_time < MAX_FLOOR_AIRBORNE_TIME

	# Process jump.
	if jumping:
		if velocity.y > 0:
			# Set off the jumping flag if going down.
			jumping = false
		elif not jump:
			stopping_jump = true

		if stopping_jump:
			velocity.y += STOP_JUMP_FORCE * step

	if on_floor:
		# Process logic when character is on floor.
		if move_left and not move_right:
			if velocity.x > -WALK_MAX_VELOCITY:
				velocity.x -= WALK_ACCEL * step
		elif move_right and not move_left:
			if velocity.x < WALK_MAX_VELOCITY:
				velocity.x += WALK_ACCEL * step
		else:
			var xv = abs(velocity.x)
			xv -= WALK_DEACCEL * step
			if xv < 0:
				xv = 0
			velocity.x = sign(velocity.x) * xv

		# Check jump.
		if not jumping and jump:
			velocity.y = -JUMP_VELOCITY
			jumping = true
			stopping_jump = false

		# Check siding.
		if velocity.x < 0 and move_left:
			new_siding_left = true
		elif velocity.x > 0 and move_right:
			new_siding_left = false
		if jumping:
			new_anim = "jumping"
		elif abs(velocity.x) < .1:
			if shoot_time < MAX_SHOOT_POSE_TIME:
				new_anim = "idle_weapon"
			else:
				new_anim = "idle"
		else:
			if shoot_time < MAX_SHOOT_POSE_TIME:
				new_anim = "run_weapon"
			else:
				new_anim = "run"
	else:
		# Process logic when the character is in the air.
		if move_left and not move_right:
			if velocity.x > -WALK_MAX_VELOCITY:
				velocity.x -= AIR_ACCEL * step
		elif move_right and not move_left:
			if velocity.x < WALK_MAX_VELOCITY:
				velocity.x += AIR_ACCEL * step
		else:
			var xv = absf(velocity.x)
			xv -= AIR_DEACCEL * step
			if xv < 0:
				xv = 0
			velocity.x = sign(velocity.x) * xv

		if velocity.y < 0:
			if shoot_time < MAX_SHOOT_POSE_TIME:
				new_anim = "jumping_weapon"
			else:
				new_anim = "jumping"
		else:
			if shoot_time < MAX_SHOOT_POSE_TIME:
				new_anim = "falling_weapon"
			else:
				new_anim = "falling"
			
	# Update siding.
#	if new_siding_left != siding_left:
#		if new_siding_left:
#			play_flip(-1)
#		else:
#			play_flip(1)
#		siding_left = new_siding_left

	# Change animation.
	if new_anim != anim:
		anim = new_anim
		
	# Apply floor velocity.
	if found_floor:
		floor_h_velocity = state.get_contact_collider_velocity_at_position(floor_index).x
		velocity.x += floor_h_velocity

	# Finally, apply gravity and set back the linear velocity.
	velocity += state.get_total_gravity() * step
	state.set_linear_velocity(velocity)
	
	if f_interact:
		state.apply_impulse(Vector2(4600*5,-3000*5), Vector2(-230*5,0))
#		state.apply_torque_impulse(60000)
	
#	state.transform = new_transform
	play_walk(velocity)
	player_flip()

func player_flip() -> void:
	var cursor_pos = get_global_mouse_position() - global_position
	var tween = create_tween()
	tween.tween_property(visual, "scale:x", sign(cursor_pos.x), .15)
	visual.rotation_degrees = -5 * sign(cursor_pos.x)
	
func play_walk(velocity: Vector2) -> void:
	if abs(velocity.x) > 100:
		animation_player.play("walk")
	else:
		animation_player.pause()
