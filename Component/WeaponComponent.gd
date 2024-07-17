extends Node
class_name WeaponComponent

signal strength_changing(strength)
signal attack_pressed()
signal attack_released()
signal attack_cooldown()

@export var max_strength: float = 1.0
@export var max_strength_increment: float = 1.0
@export var max_strength_decrement: float = 1.0

const MIN_STRENGTH = 0.0

var is_cooldown = false

var strength: float = 0.0
var strength_increment: float
var strength_decrement: float

func _process(delta):
	emit_signal("strength_changing", strength)
	if not is_cooldown:
		strength += strength_increment * delta
		
		if Input.is_action_just_pressed("attack"):
			strength_increment = max_strength_increment
			emit_signal("attack_pressed")
		if Input.is_action_just_released("attack"):
			strength_increment = 0
			emit_signal("attack_released")
			is_cooldown = true
	
		if strength >= max_strength:
			strength_increment = 0
			strength = max_strength
			emit_signal("attack_released")
			is_cooldown = true
	else:
		strength_decrement = max_strength_decrement
		strength -= strength_decrement * delta
		emit_signal("attack_cooldown")
		
		if strength <= MIN_STRENGTH:
			strength_decrement = 0
			strength = MIN_STRENGTH
			is_cooldown = false
	print(strength)
	
func shoot():
	strength = max_strength
