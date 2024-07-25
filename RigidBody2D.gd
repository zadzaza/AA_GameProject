extends RigidBody2D

func push(force_var: Vector2) -> void:
	apply_central_impulse(force_var * 0.16)
	apply_torque_impulse(force_var.x * 0.16)
