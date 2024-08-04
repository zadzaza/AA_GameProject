extends Node2D
class_name DefenceTower
# Этот скрипт управляет башней защиты, её здоровьем и взаимодействиями с игроком и врагами

enum TOWER_TEAM {
	TEAM1,
	TEAM2
}
@export var current_tower_team: TOWER_TEAM
@export var max_strength_value: int  # Максимальное значение прочности башни

@onready var offset_area: Area2D = $OffsetArea
@onready var creep_area: Area2D = $CreepArea
@onready var tower_strength: ProgressBar = $TowerStrength  # Индикатор прочности башни
@onready var interact_tower_btn_spawn: Marker2D = $InteractTowerBtnSpawn  # Позиция для кнопки взаимодействия с башней
@onready var add_creep_btn_spawn: Marker2D = $AddCreepBtnSpawn  # Позиция для кнопки добавления врагов
@onready var watchtower_spawn: Marker2D = $WatchtowerSpawn
@onready var creep_spawn: Marker2D = $CreepSpawn
@onready var interact_tower_btn: Control = load("res://UI/Interaction/interact_tower_btn.tscn").instantiate()  # Кнопка взаимодействия с башней
@onready var add_creep_btn: Control = load("res://UI/Interaction/add_creep_btn.tscn").instantiate()  # Кнопка добавления врагов
@onready var entity_layer: Node2D = get_tree().get_first_node_in_group("entity_layer")  # Слой сущностей

func _ready() -> void:
	var player_ui: Control = get_tree().get_first_node_in_group("player_ui")  # Ссылка на UI игрока
	
	tower_strength.value = max_strength_value  # Установка начального значения прочности башни

	player_ui.add_child(interact_tower_btn)  # Добавление кнопки взаимодействия с башней в UI
	player_ui.add_child(add_creep_btn)  # Добавление кнопки добавления врагов в UI
	interact_tower_btn.global_position = interact_tower_btn_spawn.global_position  # Установка позиции кнопки взаимодействия
	add_creep_btn.global_position = add_creep_btn_spawn.global_position  # Установка позиции кнопки добавления врагов
	
	if current_tower_team == TOWER_TEAM.TEAM1:
		self.scale.x = 1
	else:
		self.scale.x = -1

func _process(delta: float) -> void:
	var detected_bodies = offset_area.get_overlapping_bodies()
	if detected_bodies:
		for body in detected_bodies:
			var offset_x = (body.global_position.x - self.global_position.x) * scale.x
			if offset_x < 0:
				body.z_index = 0
			else:
				body.z_index = 1

func _on_offset_area_body_exited(body: Node2D) -> void:
	body.z_index = 1

func _on_watchtower_area_body_entered(player: Player) -> void:
	player.z_index = 0
	player.get_current_weapon().z_index = 1  # Получение оружия, изменение z_index для отображения поверх башни

func _on_watchtower_area_body_exited(player: Player) -> void:
	player.z_index = 1
	player.get_current_weapon().z_index = 0
	
func _on_button_visible_area_body_entered(player: Player) -> void:
	player.interact.connect(_on_player_interact)  # Когда игрок нажимает E
	player.creep_spawn.connect(_on_player_creep_spawn)  # Когда игрок нажимает Q
	
	add_creep_btn.open()  # Открытие кнопки добавления врагов
	interact_tower_btn.open()  # Открытие кнопки взаимодействия с башней
	
func _on_button_visible_area_body_exited(player: Player) -> void:
	player.interact.disconnect(_on_player_interact)
	player.creep_spawn.disconnect(_on_player_creep_spawn)
	
	add_creep_btn.close()  # Закрытие кнопки добавления врагов
	interact_tower_btn.close()  # Закрытие кнопки взаимодействия с башней

func _on_player_interact(player: Player):
	player.replace_to_pos(watchtower_spawn.global_position)

func _on_player_creep_spawn(player: Player):
	for body in creep_area.get_overlapping_bodies():
		if body is Creep:
			return
	
	var creep: Creep = load("res://Scenes/Creep/creep.tscn").instantiate()
	
	if current_tower_team == TOWER_TEAM.TEAM1:
		creep.set_collision_layer_value(7, true)  # Значение 7 - creep_team1
	else:
		creep.set_collision_layer_value(8, true)  # Значение 8 - creep_team2
		
	creep.scale.x = self.scale.x
	entity_layer.add_child(creep)
	creep.global_position = creep_spawn.global_position

func apply_damage(damage_value: int, block_name: String, offset: float):
	tower_strength.value -= damage_value  # Уменьшение прочности башни

	animate_block(block_name, offset)

func animate_block(block_name: String, offset: float):
	var tween = create_tween().set_parallel() # Создание параллельной анимации
	var shake_block = get_node(NodePath(block_name + "/" + block_name)) # Поиск блока, к которому применять анимацию
	tween.tween_property(shake_block, "position:x", 0, 0.2).from((7 * offset) * scale.x) # Изменение позиции блока
	tween.tween_property(shake_block, "modulate", Color.WHITE, 0.2).from(Color(0.75, 0.75, 0.75, 1.0)) # Изменение modulate блока от сероватого к нативному
