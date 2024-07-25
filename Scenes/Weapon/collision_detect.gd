extends RayCast2D

@export var strength: float = 25000
@export var damage_value: int

func _process(delta: float) -> void:
	if self.is_colliding():
		var object = self.get_collider()
		var object_pos = object.global_position
		
		if object is Player:
			object.push(self.global_position.direction_to(object_pos) * 25000)
		if object.name == "PlayerCollision":
			object.get_parent().apply_damage(damage_value)
		
		get_parent().queue_free()
