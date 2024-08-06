extends CharacterBody2D
class_name Creep

signal cooldown(is_cooldown: bool)

const GRAVITY = 20

@onready var walk_animation: AnimationPlayer = $WalkAnimation
@onready var visual: Node2D = $Visual
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var union_detected: bool = false
var creep_detected: bool = false

var health: int = 100

func _ready() -> void:
	var creep_check_area: Area2D = $CreepCheckArea
	var union_creep_check_area: Area2D = $UnionCreepCheckArea

	if self.get_collision_layer_value(7):
		creep_check_area.set_collision_mask_value(8, true)
		union_creep_check_area.set_collision_mask_value(7, true)
	elif self.get_collision_layer_value(8):
		creep_check_area.set_collision_mask_value(7, true)
		union_creep_check_area.set_collision_mask_value(8, true)

func _physics_process(delta: float) -> void:
	if abs(velocity.x) > 10:
		walk_animation.play("walk")
	else:
		walk_animation.pause()
	
	velocity.y += GRAVITY
	move_and_slide()

func push_up(damage: int) -> void:
	health -= damage
	if health <= 0:
		self.set_collision_mask_value(1, false)
	
	cooldown.emit(true)
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE), 0.25).from(Color(100, 100, 100, 1.0))
	
	velocity.y -= 200
	
	await tween.finished
	
	cooldown.emit(false)


func _on_union_creep_check_area_body_entered(creep: Creep) -> void:
	union_detected = true

func _on_union_creep_check_area_body_exited(creep: Creep) -> void:
	union_detected = false

func _on_creep_check_area_body_entered(creep: Creep) -> void:
	creep_detected = true

func _on_creep_check_area_body_exited(creep: Creep) -> void:
	creep_detected = false
