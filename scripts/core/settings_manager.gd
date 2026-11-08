class_name SettingsManager
extends Node

## Gerenciador de Configurações e Acessibilidade (RNF-05, CA-15, Seção 10.3)
## Permite desligar ou reduzir tremor de tela, hit-stop e flashes para conforto visual.

@export var screen_shake_intensity: float = 1.0 # 0.0 a 1.0
@export var hit_stop_enabled: bool = true
@export var damage_numbers_enabled: bool = true
@export var flashes_enabled: bool = true
@export var photosensitivity_mode: bool = false # Troca flash branco por brilho suave

func _ready() -> void:
	add_to_group("settings")

## Atualiza intensidade do tremor de tela (CA-15)
func set_screen_shake(intensity: float) -> void:
	screen_shake_intensity = clampf(intensity, 0.0, 1.0)

## Alterna hit-stop (CA-15)
func set_hit_stop(enabled_flag: bool) -> void:
	hit_stop_enabled = enabled_flag

## Alterna números de dano flutuantes
func set_damage_numbers(enabled_flag: bool) -> void:
	damage_numbers_enabled = enabled_flag
