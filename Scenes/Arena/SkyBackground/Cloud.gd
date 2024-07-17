extends Node2D

@onready var cloud: Sprite2D = $Sprite2D
var cloud_sprites: Array = [preload("res://Sprites/Tiles/background_cloudA.png"), preload("res://Sprites/Tiles/background_cloudB.png")]
var speed = randf_range(55.0, 65.0)

func _ready() -> void:
	var choosed_sprite = cloud_sprites[randi() % cloud_sprites.size()]
	cloud.texture = choosed_sprite
	move_cloud()

func move_cloud() -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_position:x", 2900.0, speed)
	await tween.finished
	self.queue_free()
