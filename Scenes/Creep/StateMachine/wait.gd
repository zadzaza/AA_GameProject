extends State
class_name Wait

@export var creep: Creep
@export var union_creep_check_area: Area2D

func enter() -> void:
	creep.velocity.x = 0

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func _on_union_creep_check_area_body_exited(creep: Creep) -> void:
	transitioned.emit(self, "move")
