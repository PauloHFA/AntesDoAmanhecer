extends Node2D

## Harness de Benchmark de Desempenho (CA-14, RNF-01)
## Avalia FPS e tempo de simulação com grande volume de entidades.

@export var target_enemy_count: int = 1000
@export var sample_window_frames: int = 120

var frame_times: Array[float] = []
var simulation_times_usec: Array[float] = []

@onready var stats_label: Label = $CanvasLayer/StatsLabel

func _ready() -> void:
	print("[BENCHMARK] Inicializando benchmark com %d entidades..." % target_enemy_count)

func _process(_delta: float) -> void:
	var current_fps: float = Engine.get_frames_per_second()
	var current_frame_ms: float = 1000.0 / maxf(current_fps, 1.0)
	
	frame_times.append(current_frame_ms)
	if frame_times.size() > sample_window_frames:
		frame_times.pop_front()
		
	var avg_ms: float = 0.0
	for t in frame_times:
		avg_ms += t
	avg_ms /= float(maxi(frame_times.size(), 1))
	
	if stats_label:
		stats_label.text = "Benchmark: %d entidades\nFPS: %.1f | Frame: %.2f ms (Meta: <= 16.6 ms)" % [
			target_enemy_count,
			current_fps,
			avg_ms
		]
