extends RigidBody2D

@onready var gun_visual: Node2D = $GunVisual
@onready var timer: Timer = $Timer
@onready var bullet_spawn: Marker2D = $GunVisual/Sprites/BulletSpawn
@onready var explosion: CPUParticles2D = $GunVisual/Sprites/Explosion
@onready var trajectory: Line2D = $Trajectory
@onready var arena_node: Node2D = get_parent().get_parent().get_parent()
@onready var player: Player = get_parent().get_parent()

var can_shoot: bool = true
var is_stun: bool = false
var firing_force: float = 500.0

func _ready() -> void:
	player.stun.connect(_on_stun)

func _physics_process(delta: float) -> void:
	if can_shoot and not is_stun:
		if Input.is_action_just_pressed("attack"):
			var mouse_vec = global_position.direction_to(get_global_mouse_position())
			var bullet = load("res://Scenes/Weapon/Gun/Bullet.tscn").instantiate()
			
			add_child(bullet)
			bullet.reparent(arena_node)
			bullet.global_transform = bullet_spawn.global_transform
			bullet.vel = bullet.transform.x * firing_force
			
			explosion.gravity.x = mouse_vec.x
			explosion.gravity.y = mouse_vec.y
			explosion.emitting = true
			
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
	can_shoot = true

func _on_stun(is_stun: bool):
	self.is_stun = is_stun
