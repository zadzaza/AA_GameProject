extends RigidBody2D

var push_pos: Vector2
var is_push: bool = false

func _integrate_forces(state) -> void:
	if is_push:
		#state.apply_impulse(Vector2(4600*5,-3000*5), Vector2(-230*5,0))
		state.apply_central_force(-push_pos * 50000)
		is_push = false

func push_body(pos: Vector2) -> void:
	push_pos = to_local(pos)
	is_push = true
