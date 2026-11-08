class_name PassiveManager
extends Node

## Gerenciador de Passivas Ativas do Vigilante (Seção 7.2)
## Modifica atributos de armadura, vida máxima, velocidade e regeneração.

@export var player_path: NodePath
var player_ref: Player = null

# Dicionário de passivas: passive_id -> nível atual (1 a 5)
var equipped_passives: Dictionary = {}

var regen_timer: float = 0.0

func _ready() -> void:
	if player_path:
		player_ref = get_node_or_null(player_path) as Player
	if not player_ref:
		_find_player()

func _process(delta: float) -> void:
	if equipped_passives.has("garrafada") and is_instance_valid(player_ref):
		var regen_level: int = equipped_passives["garrafada"]
		regen_timer += delta
		# Nível 1 cura 1 PV a cada 4s; níveis superiores curam mais rápido
		var interval: float = maxf(1.0, 4.0 - (regen_level * 0.5))
		if regen_timer >= interval:
			regen_timer = 0.0
			player_ref.heal(regen_level)

## Aplica ou sobe de nível uma passiva
func add_or_upgrade_passive(passive_id: String) -> int:
	if not equipped_passives.has(passive_id):
		equipped_passives[passive_id] = 1
	else:
		equipped_passives[passive_id] = mini(equipped_passives[passive_id] + 1, 5)
		
	var lvl: int = equipped_passives[passive_id]
	_apply_stat_effects(passive_id, lvl)
	return lvl

func get_equipped_passive_ids() -> Array[String]:
	var list: Array[String] = []
	for k in equipped_passives:
		list.append(str(k))
	return list

func is_passive_max_level(passive_id: String) -> bool:
	return equipped_passives.get(passive_id, 0) >= 5

func _apply_stat_effects(passive_id: String, level: int) -> void:
	if not is_instance_valid(player_ref):
		_find_player()
		if not is_instance_valid(player_ref):
			return
			
	match passive_id:
		"chapeu_de_couro":
			# Mais vida máxima (+25 PV por nível)
			var old_max: int = player_ref.max_health
			player_ref.max_health = 100 + (level * 25)
			player_ref.current_health += (player_ref.max_health - old_max)
		"ferradura":
			# Mais velocidade (+12% por nível)
			player_ref.base_speed = 120.0 * (1.0 + (level * 0.12))

func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as Player
