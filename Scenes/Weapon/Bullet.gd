extends CharacterBody2D

@export var greatest_force: int = 100
@export var farthest_mar: int = 50

@onready var physic_component: Node = $PhysicComponent
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var arena_node: Node2D = get_parent()

var mouse_vec: Vector2
const SPEED = 80000

func _ready() -> void:
	mouse_vec = global_position.direction_to(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	var angle = mouse_vec.angle()
	global_rotation = angle
	velocity = (mouse_vec * SPEED) * delta
	move_and_slide()
	
	if ray_cast.is_colliding():
		var object = ray_cast.get_collider()
		var object_pos: Vector2 = object.global_position
		
		object.force_var = physic_component.find_force(object_pos, ray_cast)
		object.push()
		
		self.queue_free()
