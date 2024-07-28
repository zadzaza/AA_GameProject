extends Control

@onready var btn: AnimatedSprite2D = $VBoxContainer/Btn/Btn

func _ready() -> void:
	btn.play("default")
	self.scale = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("creep_spawn"):
		btn.play("pressed")
	if event.is_action_released("creep_spawn"):
		btn.play("default")

func open() -> void:
	var tween = create_tween()
	
	#tween.tween_property(
		#self, 'scale', Vector2.ZERO, 0
	#)
	tween.tween_property(
		self, 'scale', Vector2.ONE, .3
	).set_ease(
		Tween.EASE_OUT
	).set_trans(
		Tween.TRANS_BACK
	)

func close():
	var tween = create_tween()
	
	#tween.tween_property(
		#self, 'scale', Vector2.ONE, 0
	#)
	tween.tween_property(
		self, 'scale', Vector2.ZERO, .3
	).set_ease(
		Tween.EASE_IN
	).set_trans(
		Tween.TRANS_BACK
	)
