extends State
class_name Attack

@export var creep: Creep
@export var creep_check_area: Area2D
@export var basic_attack_cooldown: float

var timer: Timer = Timer.new()
var creep_is_cooldown: bool = false

func enter() -> void:
	print("ENTER")
	creep.cooldown.connect(_on_creep_cooldown)
	
	add_child(timer)
	creep.velocity.x = 0
	
	timer.one_shot = false
	timer.autostart = false
	
	timer.start()
	
	timer.timeout.connect(_on_timer_timeout)

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func _on_creep_cooldown(is_cooldown: bool):
	creep_is_cooldown = is_cooldown

func _on_timer_timeout():
	if creep_check_area.get_overlapping_bodies():
		if not creep_is_cooldown:
			timer.wait_time = randf_range(0.3, 1.0) + basic_attack_cooldown
			creep_check_area.get_overlapping_bodies()[0].push_up(20)
