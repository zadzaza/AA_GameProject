extends RigidBody2D
class_name Creep

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("creep_spawn"):
		$AnimationPlayer.play("new_animation")

func push_up() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE), 0.25).from(Color(100, 100, 100, 1.0))
	
	apply_central_impulse(Vector2.UP * 200)
