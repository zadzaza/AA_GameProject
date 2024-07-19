extends RigidBody2D

@onready var gun_visual: Node2D = $GunVisual
@onready var timer: Timer = $Timer
@onready var explosion_spawn: Node2D = $GunVisual/Sprites/ExplosionSpawn
@onready var sprites: Node2D = $GunVisual/Sprites
@onready var arena_node: Node2D = get_parent().get_parent()

var can_shoot = true

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and can_shoot:
		var bullet = load("res://Scenes/Weapon/Gun/Bullet.tscn").instantiate()
		var mouse_vec = global_position.direction_to(get_global_mouse_position())
		add_child(bullet)
		bullet.reparent(arena_node)
		
		bullet.transform = gun_visual.global_transform
		bullet.vel = bullet.transform.x * 500
		
		var explosion = load("res://Scenes/Effects/explosion.tscn").instantiate()
		explosion_spawn.add_child(explosion)
		explosion.gravity.x = mouse_vec.x
		explosion.gravity.y = mouse_vec.y
		explosion.emitting = true
		
		#rotation_degrees += lerp(0.0, rotation_degrees - 360 * gun_visual.scale.y, 0.1)
		position += lerp(Vector2.ZERO, mouse_vec * -Vector2(gun_visual.scale.x * 220, gun_visual.scale.x * 220), 0.1)
		position.x = clamp(position.x, -40, 40)
		position.y = clamp(position.y, -40, 40)
		
		can_shoot = false
		timer.start()

func _on_timer_timeout() -> void:
	can_shoot = true
