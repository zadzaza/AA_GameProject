extends CharacterBody2D

@onready var ray_cast = $RayCast2D

var mouse_vec: Vector2
const SPEED = 90000

func _ready() -> void:
	mouse_vec = global_position.direction_to(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	var angle = mouse_vec.angle()
	global_rotation = angle
	velocity = (mouse_vec * SPEED) * delta
	move_and_slide()
	
	if ray_cast.is_colliding():
		ray_cast.get_collider().push(ray_cast.get_collision_point())
		self.queue_free()
