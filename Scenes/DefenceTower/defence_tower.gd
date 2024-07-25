extends Node2D
class_name DefenceTower

@export var max_strength_value: int

@onready var tower_strength: ProgressBar = $TowerStrength

var detected_bodys: Array

func _ready() -> void:
	tower_strength.value = max_strength_value

func _process(delta: float) -> void:
	if detected_bodys:
		for body in detected_bodys:
			var offset_x = (body.global_position.x - self.global_position.x) * scale.x
			if offset_x < 0:
				body.z_index = 0
			else:
				body.z_index = 1

func _on_offset_area_body_entered(body: Node2D) -> void:
	detected_bodys.append(body)

func _on_offset_area_body_exited(body: Node2D) -> void:
	detected_bodys.erase(body)
	body.z_index = 1

func _on_watchtower_area_body_entered(player: Player) -> void:
	player.z_index = 0
	player.get_current_weapon().z_index = 1

func _on_watchtower_area_body_exited(player: Player) -> void:
	player.z_index = 1
	player.get_current_weapon().z_index = 0

func apply_damage(damage_value: int):
	tower_strength.value -= damage_value
