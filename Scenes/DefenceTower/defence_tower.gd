extends Node2D
class_name DefenceTower
# Этот скрипт управляет башней защиты, её здоровьем и взаимодействиями с игроком и врагами

@export var max_strength_value: int  # Максимальное значение прочности башни

@onready var player_ui: Control = get_tree().get_first_node_in_group("player_ui")  # Ссылка на UI игрока

@onready var tower_strength: ProgressBar = $TowerStrength  # Индикатор прочности башни
@onready var interact_tower_btn_spawn: Marker2D = $InteractTowerBtnSpawn  # Позиция для кнопки взаимодействия с башней
@onready var add_creep_btn_spawn: Marker2D = $AddCreepBtnSpawn  # Позиция для кнопки добавления врагов

@onready var interact_tower_btn: Control = load("res://UI/Interaction/interact_tower_btn.tscn").instantiate()  # Кнопка взаимодействия с башней
@onready var add_creep_btn: Control = load("res://UI/Interaction/add_creep_btn.tscn").instantiate()  # Кнопка добавления врагов

var in_watchtower: bool = false

var detected_bodys: Array  # Список обнаруженных тел для проверки на offset (не только игроков)
var detected_players: Array  # Список обнаруженных игроков для проверки на event


func _ready() -> void:
	tower_strength.value = max_strength_value  # Установка начального значения прочности башни

	player_ui.add_child(interact_tower_btn)  # Добавление кнопки взаимодействия с башней в UI
	player_ui.add_child(add_creep_btn)  # Добавление кнопки добавления врагов в UI
	interact_tower_btn.global_position = interact_tower_btn_spawn.global_position  # Установка позиции кнопки взаимодействия
	add_creep_btn.global_position = add_creep_btn_spawn.global_position  # Установка позиции кнопки добавления врагов

func _process(delta: float) -> void:
	#print(detected_players)
	if detected_bodys:
		for body in detected_bodys:
			var offset_x = (body.global_position.x - self.global_position.x) * scale.x
			if offset_x < 0:
				body.z_index = 0
			else:
				body.z_index = 1

func _input(event: InputEvent) -> void:
	pass

func _on_offset_area_body_entered(body: Node2D) -> void:
	detected_bodys.append(body)  # Добавление тела в список обнаруженных

func _on_offset_area_body_exited(body: Node2D) -> void:
	detected_bodys.erase(body)  # Удаление тела из списка обнаруженных
	body.z_index = 1

func _on_watchtower_area_body_entered(player: Player) -> void:
	player.z_index = 0
	player.get_current_weapon().z_index = 1 # Получение оружия, изменение z_index для отображения поверх башни

func _on_watchtower_area_body_exited(player: Player) -> void:
	player.z_index = 1
	player.get_current_weapon().z_index = 0

func _on_spawn_to_ground_area_body_entered(player: Player) -> void:
	in_watchtower = true # Игрок находится на башне

func _on_spawn_to_ground_area_body_exited(player: Player) -> void:
	in_watchtower = false

func _on_spawn_to_watchtower_area_body_entered(player: Player) -> void:
	in_watchtower = false # Игрок находится ниже наблюдательной башни

func _on_spawn_to_watchtower_area_body_exited(player: Player) -> void:
	in_watchtower = false
	
func _on_button_visible_area_body_entered(player: Player) -> void:
	player.player_interact.connect(_on_player_interact)
	
	add_creep_btn.open()  # Открытие кнопки добавления врагов
	interact_tower_btn.open()  # Открытие кнопки взаимодействия с башней
	
	if not detected_players.has(player):
		detected_players.append(player)

func _on_button_visible_area_body_exited(player: Player) -> void:
	player.player_interact.disconnect(_on_player_interact)
	
	add_creep_btn.close()  # Закрытие кнопки добавления врагов
	interact_tower_btn.close()  # Закрытие кнопки взаимодействия с башней
	
	if detected_players.has(player):
		detected_players.erase(player)

func _on_player_interact(player: Player):
	if player in detected_players:
		print("OK")

func add_player(player: Player):
	if not detected_players.has(player):
		detected_players.append(player)

func apply_damage(damage_value: int, block_name: String, offset: float):
	tower_strength.value -= damage_value  # Уменьшение прочности башни

	animate_block(block_name, offset)

func animate_block(block_name: String, offset: float):
	var tween = create_tween().set_parallel() # Создание параллельной анимации
	var shake_block = get_node(NodePath(block_name + "/" + block_name)) # Поиск блока, к которому применять анимацию
	tween.tween_property(shake_block, "position:x", 0, 0.2).from((7 * offset) * scale.x) # Изменение позиции блока
	tween.tween_property(shake_block, "modulate", Color.WHITE, 0.2).from(Color(0.75, 0.75, 0.75, 1.0)) # Изменение modulate блока от сероватого к нативному
