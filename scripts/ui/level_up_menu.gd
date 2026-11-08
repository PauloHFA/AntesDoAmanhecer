class_name LevelUpMenu
extends Control

## Menu de Seleção de Cartas de Poder ao Subir de Nível (RF-05, CA-03, CA-04)
## Executa com PROCESS_MODE_WHEN_PAUSED para permitir interação enquanto o jogo está pausado.
## Descarta poderes já maximizados (CA-04).

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var cards_container: HBoxContainer = $Panel/VBoxContainer/CardsContainer

const ALL_UPGRADES: Array[Dictionary] = [
	{
		"id": "passive_escapulario",
		"type": "passive",
		"title": "Escapulário",
		"desc": "+Armadura (reduz dano sofrido).",
		"icon_color": Color(0.7, 0.7, 0.85)
	},
	{
		"id": "passive_ferradura",
		"type": "passive",
		"title": "Ferradura",
		"desc": "+12% Velocidade de Movimento.",
		"icon_color": Color(0.4, 0.9, 0.6)
	},
	{
		"id": "passive_chapeu",
		"type": "passive",
		"title": "Chapéu de Couro",
		"desc": "+25 Vida Máxima.",
		"icon_color": Color(0.8, 0.5, 0.25)
	},
	{
		"id": "passive_garrafada",
		"type": "passive",
		"title": "Garrafada",
		"desc": "Regeneração periódica de vida.",
		"icon_color": Color(0.3, 0.9, 0.4)
	},
	{
		"id": "weapon_garrucha",
		"type": "weapon",
		"title": "Garrucha",
		"desc": "Arma: Dispara tiros perfurantes na direção do olhar.",
		"icon_color": Color(1.0, 0.8, 0.3)
	},
	{
		"id": "weapon_facao",
		"type": "weapon",
		"title": "Facão",
		"desc": "Arma: Golpe cortante em arco frontal que afasta monstros.",
		"icon_color": Color(1.0, 0.4, 0.3)
	},
	{
		"id": "weapon_fogo_fatuo",
		"type": "weapon",
		"title": "Fogo-Fátuo",
		"desc": "Arma: Orbes teleguiados perseguem inimigos próximos.",
		"icon_color": Color(0.2, 0.85, 1.0)
	},
	{
		"id": "weapon_sino",
		"type": "weapon",
		"title": "Sino da Capela",
		"desc": "Arma: Pulso sonoro em anel que fere e afasta monstros.",
		"icon_color": Color(1.0, 0.9, 0.5)
	},
	{
		"id": "galho_upgrade",
		"type": "upgrade",
		"title": "Ramo de Arruda Extra",
		"desc": "+1 galho orbital girando ao seu redor.",
		"icon_color": Color(0.3, 1.0, 0.6)
	}
]

var upgrade_levels: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false
	
	if has_node("/root/EventBus"):
		EventBus.level_up_triggered.connect(_on_level_up)

func _on_level_up(new_level: int) -> void:
	title_label.text = "NOVO NÍVEL ALCANÇADO: %d" % new_level
	_populate_cards()
	visible = true

func _populate_cards() -> void:
	for child in cards_container.get_children():
		child.queue_free()
		
	# Filtra cartas válidas que ainda não atingiram o nível máximo (CA-04)
	var valid_candidates: Array[Dictionary] = []
	for card in ALL_UPGRADES:
		var card_id: String = card["id"]
		var current_lvl: int = upgrade_levels.get(card_id, 0)
		var max_lvl: int = 5 if card["type"] == "passive" else 8
		if current_lvl < max_lvl:
			valid_candidates.append(card)
			
	if valid_candidates.is_empty():
		valid_candidates.append({
			"id": "gold_bonus",
			"type": "bonus",
			"title": "Bênção de Ouro",
			"desc": "Todos os poderes maximizados! +30 Ouro.",
			"icon_color": Color(1.0, 0.85, 0.2)
		})
		
	valid_candidates.shuffle()
	var selected_cards: Array = valid_candidates.slice(0, mini(3, valid_candidates.size()))
	
	for card_data in selected_cards:
		var btn: Button = _create_card_button(card_data)
		cards_container.add_child(btn)

func _create_card_button(data: Dictionary) -> Button:
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(160, 130)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var color_rect: ColorRect = ColorRect.new()
	color_rect.custom_minimum_size = Vector2(140, 24)
	color_rect.color = data["icon_color"]
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(color_rect)
	
	var t_label: Label = Label.new()
	t_label.text = data["title"]
	t_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t_label.theme_override_font_sizes/font_size = 11
	t_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(t_label)
	
	var d_label: Label = Label.new()
	d_label.text = data["desc"]
	d_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	d_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d_label.theme_override_font_sizes/font_size = 9
	d_label.theme_override_colors/font_color = Color(0.75, 0.8, 0.9)
	d_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(d_label)
	
	btn.add_child(vbox)
	btn.pressed.connect(func() -> void: _apply_card_and_close(data))
	return btn

func _apply_card_and_close(data: Dictionary) -> void:
	var power_id: String = data["id"]
	upgrade_levels[power_id] = upgrade_levels.get(power_id, 0) + 1
	
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	var player: Player = players[0] as Player if players.size() > 0 else null
	
	var passive_mgrs: Array[Node] = get_tree().get_nodes_in_group("passive_manager")
	var passive_mgr: PassiveManager = passive_mgrs[0] as PassiveManager if passive_mgrs.size() > 0 else null
	
	match power_id:
		"passive_escapulario":
			if passive_mgr: passive_mgr.add_or_upgrade_passive("escapulario")
		"passive_ferradura":
			if passive_mgr: passive_mgr.add_or_upgrade_passive("ferradura")
		"passive_chapeu":
			if passive_mgr: passive_mgr.add_or_upgrade_passive("chapeu_de_couro")
		"passive_garrafada":
			if passive_mgr: passive_mgr.add_or_upgrade_passive("garrafada")
		"weapon_garrucha":
			_equip_weapon_to_player(player, preload("res://scripts/weapons/weapon_garrucha.gd"))
		"weapon_facao":
			_equip_weapon_to_player(player, preload("res://scripts/weapons/weapon_facao.gd"))
		"weapon_fogo_fatuo":
			_equip_weapon_to_player(player, preload("res://scripts/weapons/weapon_fogo_fatuo.gd"))
		"weapon_sino":
			_equip_weapon_to_player(player, preload("res://scripts/weapons/weapon_sino.gd"))
		"galho_upgrade":
			var weapons: Array[Node] = get_tree().get_nodes_in_group("weapons")
			for w in weapons:
				if w is GalhoArruda:
					w.add_branch()
		"gold_bonus":
			if has_node("/root/EventBus"):
				EventBus.gold_collected.emit(30, 0)
				
	if has_node("/root/EventBus"):
		EventBus.power_card_selected.emit(power_id)
		
	visible = false
	get_tree().paused = false

func _equip_weapon_to_player(player: Player, weapon_script: Script) -> void:
	if not player or not weapon_script:
		return
	# Checa se já existe equipada
	for child in player.get_children():
		if child.get_script() == weapon_script:
			return # Já tem a arma
	var new_weapon: Node2D = Node2D.new()
	new_weapon.set_script(weapon_script)
	player.add_child(new_weapon)
