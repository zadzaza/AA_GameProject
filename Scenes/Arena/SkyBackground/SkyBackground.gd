extends Node2D

@onready var cloud: PackedScene = preload("res://Scenes/Arena/SkyBackground/Cloud.tscn")
@onready var timer: Timer = $Timer as Timer
var time_interval: float

func _on_Timer_timeout():
	var cloud_instance = cloud.instantiate()
	cloud_instance.position.x = -300
	cloud_instance.position.y = randf_range(50, 600)
	add_child(cloud_instance)
	
	time_interval = randf_range(10.0, 15.0)
	timer.wait_time = time_interval
