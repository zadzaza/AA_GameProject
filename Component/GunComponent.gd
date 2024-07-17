extends Node

signal shoot()
signal not_shoot()
signal break_shoot()

@export var max_cartridge_count: int = 30
@export var wait_time = 0.02 # (float, 0.0, 1.0)
@export var reload_speed: int = 3
@export var shoot_speed: int = 1

@onready var timer = $Timer

enum GUN_STATE {SHOOT, NOT_SHOOT, RELOAD}

var gun_state = GUN_STATE.NOT_SHOOT
var cartridge_count: int = max_cartridge_count

func _ready():
	timer.wait_time = wait_time

func _input(event):
	if gun_state != GUN_STATE.RELOAD:
		if Input.is_action_pressed("attack"):
			gun_state = GUN_STATE.SHOOT
			timer.start()
		if Input.is_action_just_released("attack"):
			gun_state = GUN_STATE.NOT_SHOOT

func _on_Timer_timeout():
	if gun_state == GUN_STATE.SHOOT:
#		yield(get_tree().create_timer(1.0), "timeout")
		timer.wait_time = wait_time
		cartridge_count -= shoot_speed
		
		if cartridge_count <= 0:
			gun_state = GUN_STATE.RELOAD
		
		emit_signal("shoot")
	elif gun_state == GUN_STATE.NOT_SHOOT and cartridge_count > 0:
		timer.stop()
		emit_signal("not_shoot")
	elif gun_state == GUN_STATE.RELOAD:
		cartridge_count += reload_speed
		
		if cartridge_count >= 30:
			cartridge_count = max_cartridge_count
			gun_state = GUN_STATE.NOT_SHOOT
	#print(cartridge_count)
