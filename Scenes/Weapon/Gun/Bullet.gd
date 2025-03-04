extends CharacterBody2D
class_name Bullet
# Этот скрипт управляет поведением и движением снарядов

@export var gravity = 440  # Гравитация, действующая на персонажа

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D  # Эффект взрыва
@onready var collision_detect: RayCast2D = $CollisionDetect  # Луч для обнаружения столкновений

var vel: Vector2 = Vector2.ZERO  # Вектор скорости

var mouse_vec: Vector2
const SPEED = 80000  # Скорость движения

func _ready() -> void:
	self.reset_physics_interpolation()
	
	var player_layer = get_parent().player.get_collision_layer()

	mouse_vec = global_position.direction_to(get_global_mouse_position())
	cpu_particles_2d.direction = -Vector2(mouse_vec.x, mouse_vec.y)
	cpu_particles_2d.emitting = true

	if player_layer == 2:  # Значение 2 - team1
		collision_detect.set_collision_mask_value(3, true)
		collision_detect.set_collision_mask_value(8, true)
	elif player_layer == 4:  # Значение 4 - team2
		collision_detect.set_collision_mask_value(2, true)
		collision_detect.set_collision_mask_value(7, true)

func _physics_process(delta: float) -> void:
	vel.y += gravity * delta
	position += vel * delta
	rotation = vel.angle()
	velocity = vel

	move_and_slide()
