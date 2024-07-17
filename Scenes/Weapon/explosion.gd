extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("explosion")
	await animation_player.animation_finished
	self.queue_free()
