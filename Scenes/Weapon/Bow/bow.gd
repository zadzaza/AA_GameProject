extends RigidBody2D

@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var item_arrow: Sprite2D = $BowVisual/Sprites/ItemArrow
@onready var character_hand_red: Sprite2D = $BowVisual/Sprites/CharacterHandRed

var is_pull: bool = false
var is_reload: bool = false

var hand_start_pos = -16.321
var hand_target_pos = -143.321

func _ready() -> void:
	weapon_component.attack_pressed.connect(_on_attack_pressed)
	weapon_component.attack_released.connect(_on_attack_released)
	weapon_component.attack_cooldown.connect(_on_attack_cooldown)

func _physics_process(delta: float) -> void:
	character_hand_red.position.x = clamp(character_hand_red.position.x, hand_start_pos, hand_start_pos)
	if is_pull:
		character_hand_red.position.x += lerp(hand_start_pos, hand_target_pos, 0.001)
		#$AnimationPlayer.play("pull")

func _on_attack_pressed():
	print("attack_pressed")
	#$AnimationPlayer.play("pull")
	#await $AnimationPlayer.animation_changed
	#$AnimationPlayer.stop()
	
	is_pull = true

func _on_attack_released():
	print("attack_released")
	#$AnimationPlayer.stop()
	
	is_pull = false
	is_reload = true
	
func _on_attack_cooldown(strength: float):
	pass
