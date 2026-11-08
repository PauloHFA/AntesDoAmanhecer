extends Node2D

## Cena Principal da Partida (Sprints 1, 2 e 3)
## Integração de Swarm MultiMesh, Diretor de Hordas, Relógio da Noite, Ouro e Vitória ao Amanhecer.

@onready var player: Player = $Player
@onready var progression: ProgressionManager = $ProgressionManager
@onready var swarm_manager: EnemySwarmManager = $EnemySwarmManager
@onready var horde_director: HordeDirector = $HordeDirector
@onready var night_controller: NightCycleController = $NightCycleController

@onready var health_label: Label = $CanvasLayer/HUD/TopLeft/HealthLabel
@onready var level_label: Label = $CanvasLayer/HUD/TopBar/LevelLabel
@onready var xp_bar: ProgressBar = $CanvasLayer/HUD/TopBar/XPBar
@onready var timer_label: Label = $CanvasLayer/HUD/TopRight/TimerLabel
@onready var kills_label: Label = $CanvasLayer/HUD/TopRight/KillsLabel
@onready var gold_label: Label = $CanvasLayer/HUD/TopRight/GoldLabel
@onready var victory_panel: Panel = $CanvasLayer/VictoryPanel

var total_gold_collected: int = 0

func _ready() -> void:
	if has_node("/root/EventBus"):
		EventBus.player_damaged.connect(_on_player_health_changed)
		EventBus.player_healed.connect(_on_player_health_changed)
		EventBus.player_died.connect(_on_player_died)
		EventBus.xp_collected.connect(_on_xp_updated)
		EventBus.enemy_killed.connect(_on_enemy_killed)
		EventBus.gold_collected.connect(_on_gold_collected)
		EventBus.night_clock_updated.connect(_on_night_clock_updated)
		EventBus.match_won.connect(_on_match_won)
		
	if victory_panel:
		victory_panel.visible = false
		
	_update_hud_initial()

func _update_hud_initial() -> void:
	if player and health_label:
		health_label.text = "Vida: %d / %d" % [player.current_health, player.max_health]
	if progression and level_label and xp_bar:
		level_label.text = "NV. %d" % progression.current_level
		xp_bar.max_value = progression.target_xp
		xp_bar.value = progression.current_xp
	if gold_label:
		gold_label.text = "Ouro: 0"

func _on_night_clock_updated(time_remaining_seconds: float) -> void:
	if timer_label:
		var mins: int = int(time_remaining_seconds) / 60
		var secs: int = int(time_remaining_seconds) % 60
		timer_label.text = "Relógio da Noite: %02d:%02d" % [mins, secs]

func _on_player_health_changed(current: int, max_hp: int) -> void:
	if health_label:
		health_label.text = "Vida: %d / %d" % [current, max_hp]

func _on_player_died() -> void:
	if health_label:
		health_label.text = "CANDEIA APAGADA (A Noite Engoliu a Vila)"
		health_label.modulate = Color(1.0, 0.2, 0.2)

func _on_xp_updated(_amount: int, current: int, target: int) -> void:
	if xp_bar and level_label and progression:
		level_label.text = "NV. %d" % progression.current_level
		xp_bar.max_value = max(target, 1)
		xp_bar.value = current

func _on_enemy_killed(_type: String, _pos: Vector2, _gem: bool) -> void:
	if kills_label and progression:
		kills_label.text = "Abates: %d" % progression.total_kills

func _on_gold_collected(amount: int, _total: int) -> void:
	total_gold_collected += amount
	if gold_label:
		gold_label.text = "Ouro: %d" % total_gold_collected

func _on_match_won() -> void:
	if victory_panel:
		victory_panel.visible = true
