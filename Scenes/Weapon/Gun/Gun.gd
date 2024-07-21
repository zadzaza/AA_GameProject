extends RigidBody2D

@onready var gun_visual: Node2D = $GunVisual
@onready var timer: Timer = $Timer
@onready var explosion_spawn: Marker2D = $GunVisual/Sprites/ExplosionSpawn
@onready var sprites: Node2D = $GunVisual/Sprites
@onready var trajectory: Line2D = $Trajectory
@onready var arena_node: Node2D = get_parent().get_parent()

var can_shoot = true
var firing_force: float = 500.0

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and can_shoot:
		var mouse_vec = global_position.direction_to(get_global_mouse_position())
		var bullet = load("res://Scenes/Weapon/Gun/Bullet.tscn").instantiate()
		
		add_child(bullet)
		bullet.reparent(arena_node)
		bullet.transform = gun_visual.global_transform
		bullet.vel = bullet.transform.x * firing_force
		
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
	
	if Input.is_action_pressed("aiming") and can_shoot:
		trajectory.show()
		trajectory.update_trajectory(delta, 660, 480)
		trajectory.global_position = explosion_spawn.global_position
	else:
		trajectory.hide()
	
func _on_timer_timeout() -> void:
	can_shoot = true
