extends State
class_name Move

@export var creep: Creep
@export var creep_check_area: Area2D

var speed: float
var stop_move: bool = false

func enter() -> void:
	speed = 50 * creep.scale.x

func exit() -> void:
	pass

func update(_delta: float) -> void:
	if creep_check_area.get_overlapping_bodies():
		var distance_to_creep = creep.position.distance_to(creep_check_area.get_overlapping_bodies()[0].position)
		var stop_threshold = creep.get_node("Visual/CreepSquare").texture.get_width() + 40
		if distance_to_creep < stop_threshold:
			#transitioned.emit(self, "attack")
			stop_move = true

func physics_update(_delta: float) -> void:
	creep.velocity.x = clamp(creep.velocity.x, -speed, speed)
	#if abs(creep.velocity.x) > abs(speed):
		#creep.velocity.x = speed
		
	if creep.is_on_floor():
		creep.velocity.x += speed
	
	if stop_move:
		speed = lerp(speed, 0.0, .12)
		
