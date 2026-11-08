class_name WeaponData
extends Resource

## Definição de Dados de Arma (T5, Seção 7.1)

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var max_level: int = 8
@export var current_level: int = 1

@export_group("Evolução")
@export var required_passive_id: String = ""
@export var evolved_weapon_id: String = ""
@export var evolved_name: String = ""

@export_group("Atributos")
@export var base_damage: float = 10.0
@export var cooldown: float = 1.0
@export var speed: float = 200.0
@export var area_multiplier: float = 1.0
@export var pierce_count: int = 1

func can_evolve(equipped_passives: Array[String]) -> bool:
	if current_level < max_level:
		return false
	if required_passive_id.is_empty():
		return false
	return equipped_passives.has(required_passive_id)
