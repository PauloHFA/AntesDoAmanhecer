class_name ProgressionManager
extends Node

## Gerenciador de Experiência, Nível e Pausa para Escolha de Cartas (RF-05, CA-03)
## Usa a fórmula do GDD (Seção 5.2): xp_necessario(n) = round(10 + 6*n + 0.35*n*n)

@export var current_level: int = 1
@export var current_xp: int = 0
@export var total_kills: int = 0

var target_xp: int = 16

func _ready() -> void:
	target_xp = calculate_xp_for_level(current_level)
	if has_node("/root/EventBus"):
		EventBus.xp_collected.connect(_on_xp_collected)
		EventBus.enemy_killed.connect(_on_enemy_killed)
		# Inicializa HUD
		EventBus.xp_collected.emit(0, current_xp, target_xp)

static func calculate_xp_for_level(lvl: int) -> int:
	var n: float = float(lvl)
	return int(round(10.0 + (6.0 * n) + (0.35 * n * n)))

func _on_xp_collected(amount: int, _dummy1: int, _dummy2: int) -> void:
	if amount <= 0:
		return
		
	current_xp += amount
	
	while current_xp >= target_xp:
		current_xp -= target_xp
		current_level += 1
		target_xp = calculate_xp_for_level(current_level)
		_trigger_level_up()
		
	if has_node("/root/EventBus"):
		EventBus.xp_collected.emit(0, current_xp, target_xp)

func _trigger_level_up() -> void:
	# Pausa o jogo imediatamente para a escolha (Seção 5.2 e 12.4)
	get_tree().paused = true
	if has_node("/root/EventBus"):
		EventBus.level_up_triggered.emit(current_level)

func _on_enemy_killed(_type: String, _pos: Vector2, _gem: bool) -> void:
	total_kills += 1
