extends RigidBody2D
class_name Creep

signal cooldown(is_cooldown: bool)

const MAX_SPEED: float = 160
const MIN_SPEED: float = 0
const JUMP_VELOCITY = 10000.0
const STOP_JUMP_FORCE = 1300.0

var jump_increase_ratio: float = 3.0

@onready var walk_animation: AnimationPlayer = $WalkAnimation
@onready var visual: Node2D = $Visual
@onready var sword_transform: Marker2D = $SwordTransform
@onready var sword: Sword = $Sword
@onready var sword_visual: Node2D = $Sword/Visual
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var enemy_tower: DefenceTower
@onready var check_area: Area2D = $CheckArea
@onready var attack_area: Area2D = $AttackArea
@onready var target_obj: Node2D

var is_tower_target: bool = false
var is_replace: bool = false
var pos_to_replace: Vector2

var is_punch: bool = false
var velocity: Vector2
var is_push: bool = false
var health: int = 100
var sword_offset = 33  # Положение меча относительно нуля
var in_attack_area: bool = false

func _ready() -> void:
	set_targets()
	
	sword.punch_started.connect(_on_punch_started)
	sword.punch_finished.connect(_on_punch_finished)
	
func set_targets() -> void:
	var check_area: Area2D = $CheckArea
	var towers: Array = get_tree().get_nodes_in_group("tower")
	
	if self.get_collision_layer_value(7):  # creep_team1
		check_area.set_collision_mask_value(7, false)
		check_area.set_collision_mask_value(8, true)
		
		attack_area.set_collision_mask_value(7, false)
		attack_area.set_collision_mask_value(8, true)
		
		sword.ray_cast_2d.set_collision_mask_value(7, false)
		sword.ray_cast_2d.set_collision_mask_value(8, true)
		
		for t in towers:
			if t.get_current_team() == 1:
				enemy_tower = t
				
	elif self.get_collision_layer_value(8):  # creep_team2
		check_area.set_collision_mask_value(7, true)
		check_area.set_collision_mask_value(8, false)
		
		attack_area.set_collision_mask_value(7, true)
		attack_area.set_collision_mask_value(8, false)
		
		sword.ray_cast_2d.set_collision_mask_value(7, true)
		sword.ray_cast_2d.set_collision_mask_value(8, false)
		
		for t in towers:
			if t.get_current_team() == 0:
				enemy_tower = t

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var step = state.get_step()
	var direction: Vector2
	velocity = state.get_linear_velocity()
	
	if is_tower_target:
		target_obj = enemy_tower
	else:
		var creeps_in_area = check_area.get_overlapping_bodies()
		if creeps_in_area:
			var nearest_creep: Creep = creeps_in_area[0]
			for c in creeps_in_area:
				if self.global_position.distance_to(c.global_position) < self.global_position.distance_to(nearest_creep.global_position):
					nearest_creep = c
			target_obj = nearest_creep
		else:
			is_tower_target = true
	
	if is_instance_valid(target_obj):
		direction = self.global_position.direction_to(target_obj.global_position)
		var distance = self.global_position.distance_to(target_obj.global_position)
		sword_transform.position.x = lerp(sword_transform.position.x, sign(direction.x) * sword_offset, 0.1)
		#sword_transform.rotation_degrees = lerp(sword_transform.rotation_degrees, sign(direction.x) * 0, 0.05)
		sword_visual.transform = sword_transform.transform
		
		if not is_punch:
			if attack_area.get_overlapping_bodies():
				var direction_x = signf(self.global_position.direction_to(target_obj.global_position).x)
				sword.punch(direction_x)
	
		for contact_index in state.get_contact_count():
			var collision_normal = state.get_contact_local_normal(contact_index)
			
			if collision_normal.dot(Vector2(0, -1)) > .6:
				if target_obj is Creep or (target_obj is DefenceTower and self.global_position.distance_to(target_obj.global_position) > 150):
					velocity.y -= JUMP_VELOCITY * step
				else:
					velocity.y -= (JUMP_VELOCITY * 2.75) * step
					
				is_push = false
				
	if abs(velocity.x) > 10.0:
		walk_animation.play("walk")
	else:
		walk_animation.pause()
	
	if not is_push:
		velocity.x += 2.5 * direction.x
	if abs(velocity.x) >= MAX_SPEED:
		velocity.x = sign(velocity.x) * MAX_SPEED
	
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
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE), 0.25).from(Color(100, 100, 100, 1.0))
	
	apply_central_impulse(force_var)
	
	await tween.finished
	
	cooldown.emit(false)

func replace_to_pos(pos: Vector2) -> void:
	is_replace = true
	pos_to_replace = pos

func _on_check_area_body_entered(creep: Creep) -> void:
	is_tower_target = false

func _on_punch_started():
	is_punch = true

func _on_punch_finished():
	is_punch = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	in_attack_area = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	in_attack_area = false
