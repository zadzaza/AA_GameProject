extends CPUParticles2D

func _ready() -> void:
	emitting = true
	if not emitting:
		queue_free()
