class_name PassiveData
extends Resource

## Definição de Dados de Passiva (T5, Seção 7.2)

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var max_level: int = 5
@export var current_level: int = 1

@export var stat_type: String = "armor" # armor, max_health, speed, regeneration
@export var value_per_level: float = 1.0

func is_max_level() -> bool:
	return current_level >= max_level
