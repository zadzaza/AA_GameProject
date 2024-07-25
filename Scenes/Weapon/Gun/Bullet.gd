extends CharacterBody2D

@export var gravity = 440

@onready var arena_node: Node2D = get_parent().get_parent()
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var collision_detect: RayCast2D = $CollisionDetect

var vel: Vector2 = Vector2.ZERO

var mouse_vec: Vector2
const SPEED = 80000

func _ready() -> void:
	var player_layer = get_parent().player.get_collision_layer()
	
	mouse_vec = global_position.direction_to(get_global_mouse_position())
	cpu_particles_2d.direction = -Vector2(mouse_vec.x, mouse_vec.y)
	cpu_particles_2d.emitting = true
	
	print(player_layer, get_parent().player.name)
	
	if player_layer == 2: # Значение 2 - team1
		collision_detect.set_collision_mask_value(3, true)
	elif player_layer == 4: # Значение 4 - team2
		collision_detect.set_collision_mask_value(2, true)

func _physics_process(delta: float) -> void:
	vel.y += gravity * delta
	position += vel * delta
	rotation = vel.angle()
	velocity = vel
	
	move_and_slide()
	#
	#if ray_cast.is_colliding():
		#var object = ray_cast.get_collider()
		#var object_pos: Vector2 = object.global_position
		#var explosion = load("res://Scenes/Effects/explosion.tscn").instantiate()
		#
		#object.push(self.global_position.direction_to(object_pos) * 25000)
		#
		#self.queue_free()
