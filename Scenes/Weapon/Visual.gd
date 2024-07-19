extends Node2D

func _process(delta):
	var mouse_vec = global_position.direction_to(get_global_mouse_position())
	var angle = mouse_vec.angle()
	var rot = global_rotation
	global_rotation = lerp_angle(rot, angle, 0.18)

	scale.y = sign(mouse_vec.x)
