extends Node2D

## Cena de Teste da Sprint 0: Movimentação, Câmera e HUD Básico

@onready var player: Player = $Player
@onready var health_label: Label = $CanvasLayer/HUD/VBoxContainer/HealthLabel
@onready var speed_label: Label = $CanvasLayer/HUD/VBoxContainer/SpeedLabel
@onready var pos_label: Label = $CanvasLayer/HUD/VBoxContainer/PosLabel

func _ready() -> void:
	if has_node("/root/EventBus"):
		EventBus.player_damaged.connect(_on_player_health_changed)
		EventBus.player_healed.connect(_on_player_health_changed)
		EventBus.player_died.connect(_on_player_died)
	
	_update_labels()

func _process(_delta: float) -> void:
	if player and pos_label:
		pos_label.text = "Posição: (%.1f, %.1f) | Velocidade: (%.1f, %.1f)" % [
			player.global_position.x,
			player.global_position.y,
			player.velocity.x,
			player.velocity.y
		]

func _update_labels() -> void:
	if player and health_label and speed_label:
		health_label.text = "Vida: %d / %d" % [player.current_health, player.max_health]
		speed_label.text = "Velocidade Base: %.0f px/s" % player.base_speed

func _on_player_health_changed(current: int, max_hp: int) -> void:
	if health_label:
		health_label.text = "Vida: %d / %d" % [current, max_hp]

func _on_player_died() -> void:
	if health_label:
		health_label.text = "Vida: 0 (MORTO - Candeia Apagada)"
