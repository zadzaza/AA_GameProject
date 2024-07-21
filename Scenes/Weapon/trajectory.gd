extends Line2D

@onready var weapon = get_parent().get_node("GunVisual")
@onready var explosion_spawn = get_parent().get_node("GunVisual/Sprites/ExplosionSpawn")
var max_points = 100

func update_trajectory(delta: float, firing_force: float, gravity: float) -> void:
	clear_points()
	var pos: Vector2 = Vector2.ZERO
	var vel = weapon.global_position.direction_to(explosion_spawn.global_position) * firing_force
	for i in max_points:
		add_point(pos)
		vel.y += gravity * delta
		pos += vel * delta
