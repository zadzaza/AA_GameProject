extends State
class_name Move

@export var creep: Creep
@export var creep_check_area: Area2D
@export var union_creep_check_area: Area2D

var speed: float
var is_attack: bool = false
var creep_scale: float

func enter() -> void:
	speed = 50.0
	speed *= creep.scale.x

func exit() -> void:
	pass

func update(_delta: float) -> void:
	#if creep_check_area.get_overlapping_bodies():
		#var distance_to_creep = creep.position.distance_to(creep_check_area.get_overlapping_bodies()[0].position)
		#var stop_threshold = creep.get_node("Visual/CreepSquare").texture.get_width() + 40
		#if distance_to_creep < stop_threshold:
			#is_attack = true
	pass

func physics_update(_delta: float) -> void:
	pass
	#var union_area_bodies = union_creep_check_area.get_overlapping_bodies()
	creep.velocity.x = clamp(creep.velocity.x, -speed, speed)
	##if abs(creep.velocity.x) > abs(speed):
		##creep.velocity.x = speed
	#
	#if not union_area_bodies:
	if creep.is_on_floor():
		creep.velocity.x += speed
	#else:
		#stop_move("wait")
	#
	#if is_attack:
		#stop_move("attack")
	#

func _on_union_creep_check_area_body_entered(creep: Creep) -> void:
	stop_move("wait")

func _on_creep_check_area_body_entered(creep: Creep) -> void:
	stop_move("attack")

func stop_move(state: String):
	var tween = create_tween()
	tween.tween_property(self, "speed", 0, 0.3).from(speed)
	await tween.finished
	transitioned.emit(self, state)
