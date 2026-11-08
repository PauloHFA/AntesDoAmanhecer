extends Node2D

## Cena Principal da Partida (Vertical Slice - Sprint 6)
## Integração Completa: Swarm MultiMesh, Armas, Passivas, Chefe Mapinguari, Fúria Noturna e Vitória.

@onready var player: Player = $Player
@onready var progression: ProgressionManager = $ProgressionManager
@onready var swarm_manager: EnemySwarmManager = $EnemySwarmManager
@onready var horde_director: HordeDirector = $HordeDirector
@onready var night_controller: NightCycleController = $NightCycleController

@onready var health_label: Label = $CanvasLayer/HUD/TopLeft/HealthLabel
@onready var level_label: Label = $CanvasLayer/HUD/TopBar/LevelLabel
@onready var xp_bar: ProgressBar = $CanvasLayer/HUD/TopBar/XPBar
@onready var fury_bar: ProgressBar = $CanvasLayer/HUD/TopBar/FuryBar
@onready var timer_label: Label = $CanvasLayer/HUD/TopRight/TimerLabel
@onready var kills_label: Label = $CanvasLayer/HUD/TopRight/KillsLabel
@onready var gold_label: Label = $CanvasLayer/HUD/TopRight/GoldLabel
@onready var victory_panel: Panel = $CanvasLayer/VictoryPanel
@onready var match_summary_modal: MatchSummaryModal = $CanvasLayer/MatchSummaryModal

# HUD de Chefe
@onready var boss_hud: VBoxContainer = $CanvasLayer/BossHUD
@onready var boss_name_label: Label = $CanvasLayer/BossHUD/BossNameLabel
@onready var boss_hp_bar: ProgressBar = $CanvasLayer/BossHUD/BossHPBar

var total_gold_collected: int = 0
var active_boss_ref: BossMapinguari = null

const BOSS_MAPINGUARI_SCENE: PackedScene = preload("res://scenes/enemies/boss_mapinguari.tscn")
var boss_spawned_flag: bool = false

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
		EventBus.fury_changed.connect(_on_fury_changed)
		EventBus.boss_spawned.connect(_on_boss_spawned)
		EventBus.boss_defeated.connect(_on_boss_defeated)
		
	if victory_panel:
		victory_panel.visible = false
	if boss_hud:
		boss_hud.visible = false
		
	_update_hud_initial()

func _process(_delta: float) -> void:
	# Atualiza a barra de vida do chefe se ele estiver ativo
	if is_instance_valid(active_boss_ref) and boss_hud and boss_hud.visible:
		boss_hp_bar.max_value = active_boss_ref.max_health
		boss_hp_bar.value = active_boss_ref.current_health

func _update_hud_initial() -> void:
	if player and health_label:
		health_label.text = "Vida: %d / %d" % [player.current_health, player.max_health]
	if progression and level_label and xp_bar:
		level_label.text = "NV. %d" % progression.current_level
		xp_bar.max_value = progression.target_xp
		xp_bar.value = progression.current_xp
	if gold_label:
		gold_label.text = "Ouro: 0"
	if fury_bar:
		fury_bar.max_value = 100.0
		fury_bar.value = 0.0

func _on_night_clock_updated(time_remaining_seconds: float) -> void:
	if timer_label:
		var mins: int = int(time_remaining_seconds) / 60
		var secs: int = int(time_remaining_seconds) % 60
		timer_label.text = "Relógio da Noite: %02d:%02d" % [mins, secs]
		
	# Spawna o Chefe Mapinguari aos 10 minutos (ou após 60 segundos de partida de teste)
	var elapsed: float = 1200.0 - time_remaining_seconds
	if elapsed >= 60.0 and not boss_spawned_flag:
		_spawn_mapinguari_boss()

func _spawn_mapinguari_boss() -> void:
	boss_spawned_flag = true
	if not BOSS_MAPINGUARI_SCENE or not is_instance_valid(player):
		return
	var boss: BossMapinguari = BOSS_MAPINGUARI_SCENE.instantiate() as BossMapinguari
	# Spawna um pouco acima do jogador
	boss.global_position = player.global_position + Vector2(0, -220)
	active_boss_ref = boss
	add_child(boss)

func _on_boss_spawned(b_name: String) -> void:
	if boss_hud and boss_name_label:
		boss_name_label.text = "★ CHEFE: %s - O Devorador da Noite ★" % b_name.to_upper()
		boss_hud.visible = true

func _on_boss_defeated(_b_name: String) -> void:
	if boss_hud:
		boss_hud.visible = false

func _on_fury_changed(cur: float, max_f: float) -> void:
	if fury_bar:
		fury_bar.max_value = max_f
		fury_bar.value = cur
		if cur >= max_f:
			fury_bar.modulate = Color(1.3, 1.2, 0.4) # Brilho dourado
		else:
			fury_bar.modulate = Color(1.0, 0.6, 0.2)

func _on_player_health_changed(current: int, max_hp: int) -> void:
	if health_label:
		health_label.text = "Vida: %d / %d" % [current, max_hp]

func _on_player_died() -> void:
	if health_label:
		health_label.text = "CANDEIA APAGADA (A Noite Engoliu a Vila)"
		health_label.modulate = Color(1.0, 0.2, 0.2)
		
	var elapsed: float = 1200.0 - (night_controller.time_remaining if night_controller else 1200.0)
	var final_lvl: int = progression.current_level if progression else 1
	var total_kills: int = progression.total_kills if progression else 0
	
	if match_summary_modal:
		# Breve delay dramático para acompanhar a animação de morte
		get_tree().create_timer(0.5, false, false, true).timeout.connect(func() -> void:
			match_summary_modal.show_summary(false, elapsed, final_lvl, total_kills, total_gold_collected)
		)

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
	var final_lvl: int = progression.current_level if progression else 1
	var total_kills: int = progression.total_kills if progression else 0
	
	if match_summary_modal:
		match_summary_modal.show_summary(true, 1200.0, final_lvl, total_kills, total_gold_collected)
	elif victory_panel:
		victory_panel.visible = true
