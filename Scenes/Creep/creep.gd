extends RigidBody2D
class_name Creep

signal cooldown(is_cooldown: bool)

const MAX_SPEED: float = 130
const MIN_SPEED: float = 0
const JUMP_VELOCITY = 10000.0
const STOP_JUMP_FORCE = 1300.0

@onready var walk_animation: AnimationPlayer = $WalkAnimation
@onready var visual: Node2D = $Visual
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var target_tower: DefenceTower

var is_replace: bool = false
var pos_to_replace: Vector2

var velocity: Vector2
var is_push: bool = false
var speed: float = MAX_SPEED
var health: int = 100

func _ready() -> void:
	set_targets()
	
func set_targets() -> void:
	var check_area: Area2D = $CheckArea
	var towers: Array = get_tree().get_nodes_in_group("tower")
	
	if self.get_collision_layer_value(7):  # creep_team1
		check_area.set_collision_mask_value(7, false)
		check_area.set_collision_mask_value(8, true)
		
		for t in towers:
			if t.get_current_team() == 1:
				target_tower = t
				
	elif self.get_collision_layer_value(8):  # creep_team2
		check_area.set_collision_mask_value(7, true)
		check_area.set_collision_mask_value(8, false)
		
		for t in towers:
			if t.get_current_team() == 0:
				target_tower = t

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var step = state.get_step()
	velocity = state.get_linear_velocity()
	var target_obj = target_tower
	var direction = self.global_position.direction_to(target_obj.global_position)
	
	if abs(velocity.x) > 10.0:
		walk_animation.play("walk")
	else:
		walk_animation.pause()
	
	if not is_push:
		velocity.x += 5 * direction.x
	if abs(velocity.x) >= MAX_SPEED:
		velocity.x = sign(velocity.x) * MAX_SPEED
	
	for contact_index in state.get_contact_count():
		var collision_normal = state.get_contact_local_normal(contact_index)
		
		if collision_normal.dot(Vector2(0, -1)) > .6:
			velocity.y -= JUMP_VELOCITY * step
			is_push = false
		#else:
			#velocity.y += STOP_JUMP_FORCE * step
	
	state.set_linear_velocity(velocity)

func _physics_process(delta: float) -> void:
	if is_replace:
		set_linear_velocity(Vector2.ZERO)
		self.global_position = pos_to_replace
		is_replace = false
	
func push(force_var: Vector2, damage: int) -> void:
	velocity -= force_var
	is_push = true
	cooldown.emit(true)
	
	health -= damage
	if health <= 0:
		self.set_collision_mask_value(1, false)
		$FindFloor.enabled = false
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE), 0.25).from(Color(100, 100, 100, 1.0))
	
	apply_central_impulse(force_var)
	
	await tween.finished
	
	cooldown.emit(false)

func replace_to_pos(pos: Vector2) -> void:
	self.reset_physics_interpolation()
	is_replace = true
	pos_to_replace = pos
