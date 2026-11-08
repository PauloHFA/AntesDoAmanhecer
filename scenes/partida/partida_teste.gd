extends Node2D

## Cena de Partida / Protótipo da Sprint 1 (M0 Protótipo)
## Integração de Hordas, XP, Arma Orbital (Galho de Arruda) e Escolha de Poderes com Pausa.

@onready var player: Player = $Player
@onready var progression: ProgressionManager = $ProgressionManager
@onready var spawner: SimpleSpawner = $SimpleSpawner

@onready var health_label: Label = $CanvasLayer/HUD/TopLeft/HealthLabel
@onready var level_label: Label = $CanvasLayer/HUD/TopBar/LevelLabel
@onready var xp_bar: ProgressBar = $CanvasLayer/HUD/TopBar/XPBar
@onready var timer_label: Label = $CanvasLayer/HUD/TopRight/TimerLabel
@onready var kills_label: Label = $CanvasLayer/HUD/TopRight/KillsLabel

var elapsed_seconds: float = 0.0

func _ready() -> void:
	if has_node("/root/EventBus"):
		EventBus.player_damaged.connect(_on_player_health_changed)
		EventBus.player_healed.connect(_on_player_health_changed)
		EventBus.player_died.connect(_on_player_died)
		EventBus.xp_collected.connect(_on_xp_updated)
		EventBus.enemy_killed.connect(_on_enemy_killed)
		
	_update_hud_initial()

func _process(delta: float) -> void:
	elapsed_seconds += delta
	_update_timer_display()

func _update_timer_display() -> void:
	if timer_label:
		var mins: int = int(elapsed_seconds) / 60
		var secs: int = int(elapsed_seconds) % 60
		timer_label.text = "Noite: %02d:%02d / 20:00" % [mins, secs]

func _update_hud_initial() -> void:
	if player and health_label:
		health_label.text = "Vida: %d / %d" % [player.current_health, player.max_health]
	if progression and level_label and xp_bar:
		level_label.text = "NV. %d" % progression.current_level
		xp_bar.max_value = progression.target_xp
		xp_bar.value = progression.current_xp

func _on_player_health_changed(current: int, max_hp: int) -> void:
	if health_label:
		health_label.text = "Vida: %d / %d" % [current, max_hp]

func _on_player_died() -> void:
	if health_label:
		health_label.text = "CANDEIA APAGADA (Fim da Linha)"
		health_label.modulate = Color(1.0, 0.2, 0.2)

func _on_xp_updated(_amount: int, current: int, target: int) -> void:
	if xp_bar and level_label and progression:
		level_label.text = "NV. %d" % progression.current_level
		xp_bar.max_value = max(target, 1)
		xp_bar.value = current

func _on_enemy_killed(_type: String, _pos: Vector2, _gem: bool) -> void:
	if kills_label and progression:
		kills_label.text = "Abates: %d" % progression.total_kills
