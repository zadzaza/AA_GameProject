extends RayCast2D

@export var strength: float = 25000  # Сила толчка, применяемого к объектам
@export var damage_value: int  # Значение урона, наносимого объектам
@onready var entity_layer: Node2D = get_tree().get_first_node_in_group("entity_layer")  # Слой для добавления эффектов

func _process(delta: float) -> void:
	if self.is_colliding():  # Проверка на столкновение
		var object = self.get_collider()  # Получение объекта, с которым произошло столкновение
		var object_pos = object.global_position  # Позиция объекта
		var direction_to = self.global_position.direction_to(object_pos)  # Направление от RayCast к объекту
		
		if object is Player:
			object.push(direction_to * strength)  # Применение толчка к объекту типа Player
		if object.name in ["HigherBlock", "MiddleBlock", "LowerBlock"]:
			object.get_parent().apply_damage(damage_value, object.name, sign(direction_to.x))  # Применение урона к объекту блока
			
		var explosion = load("res://Scenes/Effects/explosion.tscn").instantiate()  # Создание эффекта взрыва
		entity_layer.add_child(explosion)  # Добавление эффекта взрыва в слой сущностей
		explosion.global_position = self.get_collision_point()  # Установка позиции взрыва в точке столкновения
		
		get_parent().queue_free()  # Удаление родительского объекта после столкновения
