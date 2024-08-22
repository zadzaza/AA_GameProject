extends Area2D

func _ready() -> void:
	self.body_entered.connect(_on_area_2d_body_entered)

func _on_area_2d_body_entered(player: Player) -> void:
	player.set_collision_mask_value(4, true)
