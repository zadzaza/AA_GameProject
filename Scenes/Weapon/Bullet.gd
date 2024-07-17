extends CharacterBody2D

@export var greatest_force: int = 100
@export var farthest_mar: int = 50

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
		
		object.force_var = force_finder(object_pos)
		object.push()
		
		self.queue_free()
		
		
func force_finder(pos_of_rigid : Vector2) -> Vector2:
	var vec: Vector2 = Vector2.ZERO 
	var point_pos = ray_cast.get_collision_point()
	var x_val = 5000
	var divider: = Vector2(x_val, x_val)

	vec = divider/(pos_of_rigid - point_pos)

#postive side to clamp close x values
	if vec.x >= greatest_force:
		vec.x = greatest_force
	elif vec.x <= -greatest_force:
		vec.x = -greatest_force
#negative side to clamp close x values
	if vec.y >= greatest_force:
		vec.y = greatest_force
	elif vec.y <= -greatest_force:
		vec.y = -greatest_force

#This is to ensure that the farthest object does not experince the most amount of force
	if vec.x < farthest_mar and vec.x > -farthest_mar:
		vec = Vector2.ZERO
#		print("xes")
	if vec.y < farthest_mar and vec.y > -farthest_mar:
		vec = Vector2.ZERO
#		print("yes")

	return vec 
