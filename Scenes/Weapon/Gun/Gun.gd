extends RigidBody2D

@onready var gun_component: GunComponent = $GunComponent
@onready var gun_visual: Node2D = $GunVisual
@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer
@onready var arena_node = get_parent().get_parent()

var can_shoot = true

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and can_shoot:
		var bullet = load("res://Scenes/Weapon/Bullet.tscn").instantiate()
		add_child(bullet)
		bullet.reparent(arena_node)
		
		animation_player.play("default")
		
		var mouse_vec = global_position.direction_to(get_global_mouse_position())
		rotation_degrees += lerp(0.0, rotation_degrees - 360 * gun_visual.scale.y, 0.1)
		position += lerp(Vector2.ZERO, mouse_vec * -Vector2(gun_visual.scale.x * 100, gun_visual.scale.x * 100), 0.1)
		position.x = clamp(position.x,-40, 40)
		position.y = clamp(position.y,-40, 40)
		
		can_shoot = false
		timer.start()

func _on_timer_timeout() -> void:
	can_shoot = true
