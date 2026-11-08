class_name SimpleSpawner
extends Node2D

## Gerador de hordas básico para a Sprint 1 (M0 Protótipo)
## Gera até 300 inimigos simples em torno do jogador e mantém a densidade de combate.

@export var enemy_scene: PackedScene = preload("res://scenes/enemies/simple_enemy.tscn")
@export var max_enemies: int = 300
@export var spawn_interval: float = 0.4
@export var min_spawn_distance: float = 260.0
@export var max_spawn_distance: float = 340.0
@export var despawn_distance: float = 850.0

var current_enemy_count: int = 0
var player_ref: Node2D = null
var spawn_timer: float = 0.0
var elapsed_time: float = 0.0

func _ready() -> void:
	if has_node("/root/EventBus"):
		EventBus.enemy_killed.connect(_on_enemy_killed)
	_find_player()

func _process(delta: float) -> void:
	elapsed_time += delta
	spawn_timer += delta
	
	if not is_instance_valid(player_ref):
		_find_player()
		return
		
	# Acelera ligeiramente a taxa de geração com o passar dos minutos
	var dynamic_interval: float = maxf(0.12, spawn_interval - (elapsed_time * 0.002))
	
	if spawn_timer >= dynamic_interval:
		spawn_timer = 0.0
		if current_enemy_count < max_enemies:
			_spawn_enemy()

func _spawn_enemy() -> void:
	if not enemy_scene or not is_instance_valid(player_ref):
		return
		
	# Posição aleatória em anel em torno do jogador fora da tela
	var angle: float = randf() * TAU
	var distance: float = randf_range(min_spawn_distance, max_spawn_distance)
	var spawn_pos: Vector2 = player_ref.global_position + (Vector2(cos(angle), sin(angle)) * distance)
	
	var enemy: Node2D = enemy_scene.instantiate() as Node2D
	enemy.global_position = spawn_pos
	
	# Escala leve de vida conforme o tempo (crescimento da Seção 8.2)
	var minutes: float = elapsed_time / 60.0
	var health_mult: float = 1.0 + (0.08 * minutes)
	if "max_health" in enemy:
		enemy.max_health *= health_mult
		enemy.current_health = enemy.max_health
		
	get_parent().add_child(enemy)
	current_enemy_count += 1

func _on_enemy_killed(_type: String, _pos: Vector2, _gem: bool) -> void:
	current_enemy_count = maxi(0, current_enemy_count - 1)

func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as Node2D
