class_name HordeDirector
extends Node

## Diretor de Hordas Baseado em Orçamento de Ameaça (RF-03, CA-09, Seção 8.2)
## Gerencia formações táticas, escala de dificuldade e orçamento de monstros.

enum FormationType {
	RING,     ## Anel ao redor do jogador
	WALL,     ## Parede avançando de um dos eixos
	SURGE,    ## Surto rápido concentrado
	STREAM    ## Linha cruzando a tela
}

@export var enabled: bool = true
@export var swarm_manager_path: NodePath
@export var match_duration_seconds: float = 1200.0 # 20 minutos

var elapsed_seconds: float = 0.0
var next_formation_timer: float = 10.0 # Primeira formação aos 10s
var threat_budget: float = 0.0

var swarm_manager: EnemySwarmManager = null
var player_ref: Node2D = null

func _ready() -> void:
	if swarm_manager_path:
		swarm_manager = get_node_or_null(swarm_manager_path) as EnemySwarmManager
	if not swarm_manager:
		var swarms: Array[Node] = get_tree().get_nodes_in_group("swarm_manager")
		if swarms.size() > 0:
			swarm_manager = swarms[0] as EnemySwarmManager
			
	_find_player()

func _physics_process(delta: float) -> void:
	if not enabled or not is_instance_valid(swarm_manager):
		return
		
	elapsed_seconds += delta
	next_formation_timer -= delta
	
	if not is_instance_valid(player_ref):
		_find_player()
		return
		
	var current_minute: float = elapsed_seconds / 60.0
	
	# Aciona formações táticas a cada 18 a 25 segundos
	if next_formation_timer <= 0.0:
		next_formation_timer = randf_range(16.0, 24.0)
		_trigger_random_formation(current_minute)

## Calcula a vida escalonada conforme Seção 8.2: base * (1 + 0.08*min + 0.003*min*min)
static func calculate_health_multiplier(minutes: float) -> float:
	var m: float = maxf(minutes, 0.0)
	return 1.0 + (0.08 * m) + (0.003 * m * m)

func _trigger_random_formation(minutes: float) -> void:
	var player_pos: Vector2 = player_ref.global_position
	var health_mult: float = calculate_health_multiplier(minutes)
	var base_hp: float = 20.0 * health_mult
	var base_spd: float = 65.0
	
	# Quantidade de monstros cresce com os minutos
	var count: int = int(clampi(int(20 + (minutes * 12)), 20, 180))
	
	var r: float = randf()
	if r < 0.4:
		spawn_ring_formation(player_pos, count, base_hp, base_spd, 320.0)
	elif r < 0.75:
		var dir_idx: int = randi() % 4
		var side_dir: Vector2 = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT][dir_idx]
		spawn_wall_formation(player_pos, side_dir, count, base_hp, base_spd)
	else:
		spawn_surge_formation(player_pos, int(count * 0.7), base_hp * 0.8, base_spd * 1.3)

## Formação 1: Anel de cerco ao redor do jogador
func spawn_ring_formation(center: Vector2, count: int, hp: float, spd: float, radius: float = 320.0) -> void:
	if not swarm_manager:
		return
	var step: float = TAU / float(maxi(count, 1))
	for i in range(count):
		var angle: float = i * step
		var pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius
		swarm_manager.spawn_enemy(pos, hp, spd)

## Formação 2: Parede que avança de um dos lados do mapa
func spawn_wall_formation(center: Vector2, from_dir: Vector2, count: int, hp: float, spd: float) -> void:
	if not swarm_manager:
		return
	var perpendicular: Vector2 = Vector2(-from_dir.y, from_dir.x)
	var spawn_origin: Vector2 = center + (from_dir * 360.0)
	var spacing: float = 24.0
	var half_width: float = (float(count) * spacing) * 0.5
	
	for i in range(count):
		var offset: float = -half_width + (float(i) * spacing)
		var pos: Vector2 = spawn_origin + (perpendicular * offset)
		swarm_manager.spawn_enemy(pos, hp, spd)

## Formação 3: Surto rápido concentrado
func spawn_surge_formation(center: Vector2, count: int, hp: float, spd: float) -> void:
	if not swarm_manager:
		return
	var random_angle: float = randf() * TAU
	var surge_origin: Vector2 = center + Vector2(cos(random_angle), sin(random_angle)) * 340.0
	
	for i in range(count):
		var jitter: Vector2 = Vector2(randf_range(-30.0, 30.0), randf_range(-30.0, 30.0))
		swarm_manager.spawn_enemy(surge_origin + jitter, hp, spd)

func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as Node2D
