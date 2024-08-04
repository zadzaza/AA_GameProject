extends CharacterBody2D
class_name Creep

const GRAVITY = 20

@onready var walk_animation: AnimationPlayer = $WalkAnimation
@onready var visual: Node2D = $Visual
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	var creep_check_area: Area2D = $CreepCheckArea
	
	if self.get_collision_layer_value(7):
		creep_check_area.set_collision_mask_value(8, true)
	elif self.get_collision_layer_value(8):
		creep_check_area.set_collision_mask_value(7, true)

func _physics_process(delta: float) -> void:
	if abs(velocity.x) > 10:
		walk_animation.play("walk")
	else:
		walk_animation.pause()
	
	velocity.y += GRAVITY
	move_and_slide()

func push_up() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE), 0.25).from(Color(100, 100, 100, 1.0))
	
	velocity.y -= 200
