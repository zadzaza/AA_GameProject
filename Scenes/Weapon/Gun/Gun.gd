extends RigidBody2D
# Этот скрипт управляет стрельбой и эффектами оружия

@onready var gun_visual: Node2D = $GunVisual  # Визуальная часть оружия
@onready var timer: Timer = $Timer  # Таймер для задержки стрельбы
@onready var bullet_spawn: Marker2D = $GunVisual/Sprites/BulletSpawn  # Позиция спавна пуль
@onready var explosion: CPUParticles2D = $GunVisual/Sprites/Explosion  # Эффект взрыва
@onready var trajectory: Line2D = $Trajectory  # Линия для отображения траектории
@onready var entity_layer: Node2D = get_tree().get_first_node_in_group("entity_layer")  # Слой сущностей
@onready var player: Player = get_parent().get_parent()  # Ссылка на игрока

var can_shoot: bool = true  # Флаг возможности стрельбы
var is_stun: bool = false  # Флаг оглушения
var firing_force: float = 500.0  # Сила выстрела

var is_replace: bool = false
var pos_to_replace: Vector2

func _ready() -> void:
	player.stun.connect(_on_player_stun)  # Подключение к сигналу оглушения

func _physics_process(delta: float) -> void:
	if can_shoot and not is_stun:
		if Input.is_action_just_pressed("attack"):
			var mouse_vec = self.global_position.direction_to(get_global_mouse_position())
			var bullet = load("res://Scenes/Weapon/Gun/Bullet.tscn").instantiate()

			add_child(bullet)
			bullet.reparent(entity_layer)
			bullet.global_transform = bullet_spawn.global_transform
			bullet.vel = bullet.transform.x * firing_force

			explosion.gravity.x = mouse_vec.x
			explosion.gravity.y = mouse_vec.y
			explosion.restart()

			#gun_visual.rotation_degrees += lerp(0.0, rotation_degrees - 360 * gun_visual.scale.y, 0.1)
			position += lerp(Vector2.ZERO, mouse_vec * -Vector2(gun_visual.scale.x * 220, gun_visual.scale.x * 220), 0.1)
			position.x = clamp(position.x, -40, 40)
			position.y = clamp(position.y, -40, 40)

			can_shoot = false
			
			timer.start()

		if Input.is_action_pressed("aiming"):
			trajectory.show()
			trajectory.update_trajectory(delta, 740, 485)
			trajectory.global_position = bullet_spawn.global_position
		else:
			trajectory.hide()
	else:
		trajectory.hide()

func _on_timer_timeout() -> void:
	can_shoot = true  # Сбрасывает возможность стрельбы после таймера

func _on_player_stun(is_stun: bool):
	self.is_stun = is_stun  # Обновляет состояние оглушения
