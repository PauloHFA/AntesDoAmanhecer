extends Node2D

## Cena de Benchmark de Desempenho de Hordas (CA-14, RNF-01, Seção 12.2 / 12.3)
## Avalia FPS, tempo de quadro e orçamento de CPU da simulação em lote.

@export var default_enemy_count: int = 1000

@onready var swarm_manager: EnemySwarmManager = $EnemySwarmManager
@onready var player: Player = $Player
@onready var stats_label: Label = $CanvasLayer/StatsPanel/VBoxContainer/StatsLabel
@onready var cpu_bar: ProgressBar = $CanvasLayer/StatsPanel/VBoxContainer/CPUTimeBar
@onready var cpu_label: Label = $CanvasLayer/StatsPanel/VBoxContainer/CPUTimeLabel

var frame_times: Array[float] = []
var sample_size: int = 60

func _ready() -> void:
	# Ajusta jogador para não morrer no benchmark de estresse
	if player:
		player.max_health = 99999
		player.current_health = 99999
		
	# Spawna a quantidade inicial configurada
	_set_enemy_count(default_enemy_count)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_set_enemy_count(500)
			KEY_2:
				_set_enemy_count(1000)
			KEY_3:
				_set_enemy_count(1500)
			KEY_4:
				_set_enemy_count(2000)
			KEY_SPACE:
				_test_area_blast()

func _set_enemy_count(target: int) -> void:
	if not swarm_manager:
		return
		
	swarm_manager.clear_all()
	var center: Vector2 = player.global_position if is_instance_valid(player) else Vector2.ZERO
	
	for i in range(target):
		var angle: float = randf() * TAU
		var dist: float = randf_range(100.0, 480.0)
		var pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * dist
		swarm_manager.spawn_enemy(pos, 25.0, randf_range(50.0, 75.0))

func _test_area_blast() -> void:
	if not swarm_manager or not is_instance_valid(player):
		return
	# Testa detecção e impacto em massa na grade espacial
	var hits: int = swarm_manager.damage_in_radius(player.global_position, 140.0, 50.0, 30.0)
	print("[BENCHMARK] Explosão em área acertou %d inimigos via SpatialHashGrid!" % hits)

func _process(_delta: float) -> void:
	var fps: float = Engine.get_frames_per_second()
	var frame_ms: float = 1000.0 / maxf(fps, 1.0)
	
	frame_times.append(frame_ms)
	if frame_times.size() > sample_size:
		frame_times.pop_front()
		
	var avg_ms: float = 0.0
	for t in frame_times:
		avg_ms += t
	avg_ms /= float(maxi(frame_times.size(), 1))
	
	var sim_ms: float = swarm_manager.last_simulation_time_ms if swarm_manager else 0.0
	var sim_status: String = "DENTRO DA META (<= 4 ms)" if sim_ms <= 4.0 else "ATENÇÃO: ACIMA DA META"
	var sim_color: String = "#06d6a0" if sim_ms <= 4.0 else "#ef476f"
	
	if stats_label and swarm_manager:
		stats_label.text = "Inimigos Ativos: %d | FPS: %.1f\nTempo de Quadro Médio: %.2f ms\nSimulação CPU (Lote): [color=%s]%.2f ms[/color] (%s)\n[color=#ffd166]Teclas 1, 2, 3, 4: Alternar contagem (500 a 2000) | Espaço: Onda de choque[/color]" % [
			swarm_manager.active_count,
			fps,
			avg_ms,
			sim_color,
			sim_ms,
			sim_status
		]
		
	if cpu_bar and cpu_label:
		cpu_bar.max_value = 16.6 # Orçamento de 60 FPS
		cpu_bar.value = sim_ms
		cpu_label.text = "Uso de CPU da Simulação: %.2f ms / 4.0 ms meta" % sim_ms
