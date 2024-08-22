extends RigidBody2D
class_name Sword

signal punch_started
signal punch_finished

@onready var visual: Node2D = $Visual
@onready var punch_animation_pl: AnimationPlayer = $PunchAnimation
@onready var timer: Timer = $Timer
@onready var ray_cast_2d: RayCast2D = $Visual/Node2D/RayCast2D
@onready var hand: Node2D = $Visual/Node2D/Hand

var direction_x: float
var is_push: bool = false

func _ready() -> void:
	#timer.wait_time = randf_range(0.01, 0.025)
	pass

func punch(direction_x: float):
	if direction_x == 0:
		return
		
	self.direction_x = direction_x
	punch_started.emit()
	
	punch_animation_pl.play("punch_" + str(direction_x))
	await punch_animation_pl.animation_finished
	punch_animation_pl.play("return_" + str(direction_x))

	await punch_animation_pl.animation_finished
	
	punch_finished.emit()


func push() -> void:
	if ray_cast_2d.is_colliding():
		var object = ray_cast_2d.get_collider()
		if object is Creep:
			ray_cast_2d.get_collider().push(Vector2(sign(direction_x) * 50000, -20000), 35)
		if object.name in ["HigherBlock", "MiddleBlock", "LowerBlock"]:
			object.get_parent().apply_damage(2, object.name, direction_x)
