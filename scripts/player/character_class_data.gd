class_name CharacterClassData
extends Resource

## Dados e Atributos de Classe dos Vigilantes (Seção 6, RF-11)
## Define multiplicadores de vida, velocidade, dano, arma inicial e especial.

@export var class_id: String = "benzedeira"
@export var display_name: String = "Benzedeira"
@export var archetype: String = "Suporte e Área"
@export var starting_weapon_id: String = "galho_arruda"
@export var starting_weapon_script: Script

@export_group("Multiplicadores Percentuais (100 = Padrão)")
@export var health_percent: float = 100.0
@export var speed_percent: float = 100.0
@export var damage_percent: float = 100.0

@export_group("Habilidade Especial (Fúria)")
@export var special_name: String = "Reza Forte"
@export var special_description: String = "Onda sagrada que empurra e fere tudo por 5s."
@export var special_duration: float = 5.0

@export_group("Passiva Própria")
@export var passive_description: String = "Cura 1 PV a cada 5s e +10% de área."
