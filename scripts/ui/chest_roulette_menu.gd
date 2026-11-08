class_name ChestRouletteMenu
extends Control

## Menu de Abertura de Baús e Evoluções de Armas (RF-08, CA-07)
## Executa em modo WHEN_PAUSED para exibir fanfarra e recompensas ao jogador.

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var reward_label: Label = $Panel/VBoxContainer/RewardLabel
@onready var desc_label: Label = $Panel/VBoxContainer/DescLabel
@onready var claim_button: Button = $Panel/VBoxContainer/ClaimButton

var pending_gold: int = 0

func _ready() -> void:
	add_to_group("chest_menu")
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false
	claim_button.pressed.connect(_on_claim_pressed)

func open_roulette(gold_reward: int) -> void:
	pending_gold = gold_reward
	
	# Checa se alguma arma pode evoluir (CA-07)
	var passive_mgr: PassiveManager = _get_passive_manager()
	var equipped_passives: Array[String] = passive_mgr.get_equipped_passive_ids() if passive_mgr else []
	
	var weapons: Array[Node] = get_tree().get_nodes_in_group("weapons")
	var evolved_data: Dictionary = {}
	var target_weapon: Node = null
	
	for w in weapons:
		var w_id: String = ""
		if w is GalhoArruda: w_id = "galho_arruda"
		elif w is WeaponGarrucha: w_id = "garrucha"
		elif w is WeaponFogoFatuo: w_id = "fogo_fatuo"
		elif w is WeaponFacao: w_id = "facao"
		elif w is WeaponSino: w_id = "sino"
		
		# Procura evolução elegível
		var eligible: Dictionary = WeaponEvolutionManager.check_evolution_eligible(w_id, 5, equipped_passives)
		if not eligible.is_empty():
			evolved_data = eligible
			target_weapon = w
			break
			
	if not evolved_data.is_empty() and target_weapon:
		title_label.text = "★ EVOLUÇÃO DE ARMA! ★"
		title_label.modulate = Color(1.0, 0.85, 0.2)
		reward_label.text = evolved_data["evolved_name"]
		desc_label.text = evolved_data["desc"]
		if target_weapon.has_method("evolve_weapon"):
			target_weapon.evolve_weapon()
	else:
		title_label.text = "TESOURO ENCONTRADO!"
		title_label.modulate = Color(0.4, 0.9, 1.0)
		reward_label.text = "+%d Moedas de Ouro" % pending_gold
		desc_label.text = "Ouro guardado para melhorias permanentes no Candeeiro."
		
	visible = true

func _on_claim_pressed() -> void:
	if pending_gold > 0 and has_node("/root/EventBus"):
		EventBus.gold_collected.emit(pending_gold, 0)
		
	visible = false
	get_tree().paused = false

func _get_passive_manager() -> PassiveManager:
	var list: Array[Node] = get_tree().get_nodes_in_group("passive_manager")
	if list.size() > 0:
		return list[0] as PassiveManager
	return null
