extends RayCast2D

@export var strength: float = 25000  # Сила толчка, применяемого к объектам
@export var damage_value: int  # Значение урона, наносимого объектам

func _physics_process(delta: float) -> void:
	if self.is_colliding():  # Проверка на столкновение
		var object = self.get_collider()  # Получение объекта, с которым произошло столкновение
		var object_pos = object.global_position  # Позиция объекта
		var direction_to = self.global_position.direction_to(object_pos)  # Направление от RayCast к объекту
		
		if object is Bullet:
			object.queue_free()
		if object is Player:
			object.push(direction_to * strength)  # Применение толчка к объекту типа Player
			object.set_linear_velocity(direction_to * 2000)
		if object is Creep:
			object.push_up(50)  # Применение верхнего толчка к объекту типа Creep
		if object.name in ["HigherBlock", "MiddleBlock", "LowerBlock"]:
			object.get_parent().apply_damage(damage_value, object.name, sign(direction_to.x))  # Применение урона к объекту блока
			
		create_explosion()

func create_explosion():
	var entity_layer: Node2D = get_tree().get_first_node_in_group("entity_layer")  # Слой для добавления эффектов
	
	var explosion = load("res://Scenes/Effects/explosion.tscn").instantiate()  # Создание эффекта взрыва
	entity_layer.add_child(explosion)  # Добавление эффекта взрыва в слой сущностей
	explosion.global_position = self.get_collision_point()  # Установка позиции взрыва в точке столкновения
	
	get_parent().queue_free()  # Удаление родительского объекта после столкновения
