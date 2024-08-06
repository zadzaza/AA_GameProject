extends RigidBody2D
class_name Player

signal stun(is_stun: bool)
signal interact(player: Player)
signal creep_spawn(player: Player)

@export var layer = 2

const WALK_ACCEL = 1220.0 
const WALK_DEACCEL = 1220.0
const WALK_MAX_VELOCITY = 230.0
const AIR_ACCEL = 350.0
const AIR_DEACCEL = 350.0
const JUMP_VELOCITY = 455.0
const STOP_JUMP_FORCE = 525.0
const MAX_SHOOT_POSE_TIME = .3
const MAX_FLOOR_AIRBORNE_TIME = .15

var siding_left: bool = false
var jumping: bool = false
var stopping_jump: bool = false
var shooting: bool = false
var is_flipping: bool = false

var floor_h_velocity: float = 0.0

var airborne_time: float = 1e20
var shoot_time: float = 1e20

var force_var: Vector2

var is_replace: bool = false
var pos_to_replace: Vector2

@onready var visual = $VisualPlayer as Node2D
@onready var walk_animation = $WalkAnimation as AnimationPlayer
@onready var trace: CPUParticles2D = $Trace
@onready var pin_joint_2d: PinJoint2D = $PinJoint2D

func _ready() -> void:
	var current_weapon = get_current_weapon()
	
	current_weapon.position = pin_joint_2d.position
	pin_joint_2d.node_b = NodePath("../Weapon/" + current_weapon.name)
	set_collision_layer_value(layer, true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		self.interact.emit(self)
	if event.is_action_pressed("creep_spawn"):
		self.creep_spawn.emit(self)

func _process(delta: float) -> void:
	if is_replace:
		set_linear_velocity(Vector2.ZERO)
		self.global_position = pos_to_replace
		is_replace = false
		
func _integrate_forces(state) -> void:
	#if Input.is_action_just_pressed("spawn"):
		#var rigid = load("res://RigidBody2D.tscn").instantiate()
		#get_parent().add_child(rigid)
		#rigid.global_position = get_global_mouse_position()
		
#	var rotation_radians = deg2rad(rotation_degrees)
#	var new_rotation = clamp(rotation_radians, -.8, .8)
#	var new_transform = Transform2D(new_rotation, position)
	var velocity = state.get_linear_velocity()
	var step = state.get_step()
	
	# Get player input.
	var move_left = Input.is_action_pressed("ui_left")
	var move_right = Input.is_action_pressed("ui_right")
	var jump = Input.is_action_pressed("jump")
	
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

		if abs(velocity.x) > 195 and (move_left or move_right):
			trace.emitting = true
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
			
	# Apply floor velocity.
	if found_floor:
		floor_h_velocity = state.get_contact_collider_velocity_at_position(floor_index).x
		velocity.x += floor_h_velocity

	# Finally, apply gravity and set back the linear velocity.
	velocity += state.get_total_gravity() * step
	state.set_linear_velocity(velocity)
	
#	state.transform = new_transform
	play_walk(velocity)
	player_flip()

func player_flip() -> void:
	var cursor_pos = get_global_mouse_position() - global_position
	var tween = create_tween()
	tween.tween_property(visual, "scale:x", sign(cursor_pos.x), .15)
	visual.rotation_degrees = 5 * -sign(cursor_pos.x)
	
func play_walk(velocity: Vector2) -> void:
	if abs(velocity.x) > 100:
		walk_animation.play("walk")
	else:
		walk_animation.pause()

func push(force_var: Vector2) -> void:
	stun.emit(true)
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE), 0.25).from(Color(100, 100, 100, 1.0))
	
	apply_central_impulse(force_var)
	
	await tween.finished
	stun.emit(false)

func get_current_weapon() -> RigidBody2D:
	return get_node("Weapon").get_child(0) # Получение текущего оружия. Больше одного оружия быть не может

func replace_to_pos(pos: Vector2):
	self.reset_physics_interpolation()
	is_replace = true
	pos_to_replace = pos
