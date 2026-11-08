class_name StageData
extends Resource

## Definição de Dados do Estágio / Ato (Seção 3.2, RF-18)

@export var stage_id: String = "vila_candeia"
@export var display_name: String = "Vila de Candeia"
@export var act_number: int = 1
@export var description: String = "Ruas de terra, casario colonial, praça e igreja da vila."
@export var scene_path: String = "res://scenes/partida/partida_teste.tscn"

@export_group("Ambientação e Cores")
@export var ground_color: Color = Color(0.06, 0.08, 0.12, 1.0)
@export var grid_line_color: Color = Color(0.12, 0.15, 0.22, 1.0)
@export var night_tint_color: Color = Color(0.45, 0.45, 0.65, 1.0)

@export_group("Chefes do Estágio")
@export var first_boss_name: String = "Mapinguari"
@export var first_boss_minute: int = 10
@export var second_boss_name: String = "Cuca"
@export var second_boss_minute: int = 18
