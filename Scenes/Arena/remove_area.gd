extends Node2D


func _on_area_2d_body_exited(body: Node2D) -> void:
	body.queue_free()
