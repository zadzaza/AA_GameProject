extends Node

#@export var gravity: float = 440
#@export var firing_force: float = 500
#
#@onready var projectile: CharacterBody2D = get_parent()
#@onready var weapon: RigidBody2D = get_parent().get_parent()
#
#var vel: Vector2 = Vector2.ZERO
#
#func _physics_process(delta: float) -> void:
	#vel = weapon.transform.x * firing_force
	#vel.y += gravity * delta
	#
	#projectile.position += vel * delta
	#projectile.rotation = vel.angle()
	#projectile.velocity = vel
	#
	#projectile.move_and_slide()
