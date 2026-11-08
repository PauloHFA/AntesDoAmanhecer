class_name LevelUpMenu
extends Control

## Menu de Seleção de Cartas de Poder ao Subir de Nível (RF-05, CA-03)
## Executa com PROCESS_MODE_WHEN_PAUSED para permitir interação enquanto o jogo está pausado.

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var cards_container: HBoxContainer = $Panel/VBoxContainer/CardsContainer

const AVAILABLE_UPGRADES: Array[Dictionary] = [
	{
		"id": "galho_damage",
		"title": "Arruda Sagrada",
		"desc": "+25% de dano na Arruda",
		"icon_color": Color(0.3, 0.8, 0.3)
	},
	{
		"id": "galho_branches",
		"title": "Ramo Extra",
		"desc": "+1 galho orbitando em volta",
		"icon_color": Color(0.2, 0.9, 0.5)
	},
	{
		"id": "galho_speed",
		"title": "Giro Voraz",
		"desc": "+35% velocidade de rotação",
		"icon_color": Color(0.4, 1.0, 0.8)
	},
	{
		"id": "player_speed",
		"title": "Passo do Sertão",
		"desc": "+15% velocidade do Vigilante",
		"icon_color": Color(1.0, 0.85, 0.3)
	},
	{
		"id": "player_heal",
		"title": "Chama Restauradora",
		"desc": "Recupera 35 pontos de vida",
		"icon_color": Color(1.0, 0.4, 0.4)
	}
]

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
	# Limpa botões de cartas anteriores
	for child in cards_container.get_children():
		child.queue_free()
		
	# Sorteia 3 cartas distintas
	var shuffled: Array = AVAILABLE_UPGRADES.duplicate()
	shuffled.shuffle()
	var selected_cards: Array = shuffled.slice(0, 3)
	
	for card_data in selected_cards:
		var card_btn: Button = _create_card_button(card_data)
		cards_container.add_child(card_btn)

func _create_card_button(data: Dictionary) -> Button:
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(160, 130)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Ícone / Tarja colorida
	var color_rect: ColorRect = ColorRect.new()
	color_rect.custom_minimum_size = Vector2(140, 24)
	color_rect.color = data["icon_color"]
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(color_rect)
	
	# Título
	var t_label: Label = Label.new()
	t_label.text = data["title"]
	t_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t_label.theme_override_font_sizes/font_size = 11
	t_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(t_label)
	
	# Descrição
	var d_label: Label = Label.new()
	d_label.text = data["desc"]
	d_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	d_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d_label.theme_override_font_sizes/font_size = 9
	d_label.theme_override_colors/font_color = Color(0.75, 0.8, 0.9)
	d_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(d_label)
	
	btn.add_child(vbox)
	btn.pressed.connect(func() -> void: _apply_card_and_close(data["id"]))
	return btn

func _apply_card_and_close(power_id: String) -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	var player: Player = players[0] as Player if players.size() > 0 else null
	
	var weapons: Array[Node] = get_tree().get_nodes_in_group("weapons")
	var weapon: GalhoArruda = null
	if weapons.size() > 0:
		weapon = weapons[0] as GalhoArruda
	elif player:
		weapon = player.get_node_or_null("GalhoArruda") as GalhoArruda
		
	match power_id:
		"galho_damage":
			if weapon:
				weapon.increase_damage(0.25)
		"galho_branches":
			if weapon:
				weapon.add_branch()
		"galho_speed":
			if weapon:
				weapon.increase_speed(0.35)
		"player_speed":
			if player:
				player.base_speed *= 1.15
		"player_heal":
			if player:
				player.heal(35)
				
	if has_node("/root/EventBus"):
		EventBus.power_card_selected.emit(power_id)
		
	# Fecha o menu e retoma a partida
	visible = false
	get_tree().paused = false
