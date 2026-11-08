class_name CandeeiroStore
extends Control

## Loja de Melhorias Permanentes: O Candeeiro (RF-16, CA-13, Seção 9)
## Permite comprar upgrades persistentes com ouro e reembolsar livremente.

@onready var gold_label: Label = $VBoxContainer/TopBar/GoldLabel
@onready var upgrades_container: VBoxContainer = $VBoxContainer/ScrollContainer/UpgradesContainer
@onready var refund_button: Button = $VBoxContainer/BottomBar/RefundButton
@onready var back_button: Button = $VBoxContainer/BottomBar/BackButton

var save_system: SaveSystem = null

const UPGRADES_DEF: Array[Dictionary] = [
	{
		"id": "max_health",
		"name": "Chama Resistente",
		"desc": "+10 PV Máximo por nível.",
		"base_cost": 50,
		"max_level": 5
	},
	{
		"id": "global_damage",
		"name": "Calor Abrasador",
		"desc": "+5% de Dano em todas as armas por nível.",
		"base_cost": 75,
		"max_level": 5
	},
	{
		"id": "gold_gain",
		"name": "Olho de Garimpeiro",
		"desc": "+10% de Ouro obtido nas partidas por nível.",
		"base_cost": 60,
		"max_level": 5
	},
	{
		"id": "luck",
		"name": "Patuá Abençoado",
		"desc": "+5% de Sorte na qualidade das cartas e baús.",
		"base_cost": 80,
		"max_level": 5
	},
	{
		"id": "magnet_range",
		"name": "Atração da Candeia",
		"desc": "+15% Raio de atração magnética de gemas e ouro.",
		"base_cost": 45,
		"max_level": 5
	},
	{
		"id": "extra_reroll",
		"name": "Destino Dobrado",
		"desc": "+1 Reroll inicial por nível ao subir de nível.",
		"base_cost": 100,
		"max_level": 3
	}
]

func _ready() -> void:
	save_system = SaveSystem.new()
	_update_gold_display()
	_populate_upgrade_items()
	
	if refund_button: refund_button.pressed.connect(_on_refund_pressed)
	if back_button: back_button.pressed.connect(_on_back_pressed)

func _update_gold_display() -> void:
	if gold_label and save_system:
		gold_label.text = "Ouro Acumulado: %d" % save_system.total_gold

func _populate_upgrade_items() -> void:
	if not upgrades_container:
		return
		
	for child in upgrades_container.get_children():
		child.queue_free()
		
	for def in UPGRADES_DEF:
		var u_id: String = def["id"]
		var cur_lvl: int = save_system.candeeiro_upgrades.get(u_id, 0)
		var max_lvl: int = def["max_level"]
		var cost: int = def["base_cost"] * (cur_lvl + 1)
		
		var row: HBoxContainer = HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 36)
		
		var info_vbox: VBoxContainer = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var title_lbl: Label = Label.new()
		title_lbl.text = "%s (Nível %d / %d)" % [def["name"], cur_lvl, max_lvl]
		title_lbl.theme_override_font_sizes/font_size = 11
		title_lbl.theme_override_colors/font_color = Color(1.0, 0.9, 0.4)
		info_vbox.add_child(title_lbl)
		
		var desc_lbl: Label = Label.new()
		desc_lbl.text = def["desc"]
		desc_lbl.theme_override_font_sizes/font_size = 9
		desc_lbl.theme_override_colors/font_color = Color(0.7, 0.75, 0.85)
		info_vbox.add_child(desc_lbl)
		
		row.add_child(info_vbox)
		
		var buy_btn: Button = Button.new()
		buy_btn.custom_minimum_size = Vector2(100, 28)
		buy_btn.theme_override_font_sizes/font_size = 10
		
		if cur_lvl >= max_lvl:
			buy_btn.text = "MAX"
			buy_btn.disabled = true
		else:
			buy_btn.text = "Comprar (%d)" % cost
			buy_btn.disabled = (save_system.total_gold < cost)
			buy_btn.pressed.connect(func() -> void: _buy_upgrade(u_id, cost))
			
		row.add_child(buy_btn)
		upgrades_container.add_child(row)

func _buy_upgrade(upgrade_id: String, cost: int) -> void:
	if save_system.total_gold >= cost:
		save_system.total_gold -= cost
		save_system.candeeiro_upgrades[upgrade_id] = save_system.candeeiro_upgrades.get(upgrade_id, 0) + 1
		save_system.save_game()
		_update_gold_display()
		_populate_upgrade_items()

func _on_refund_pressed() -> void:
	# Calcula e devolve 100% do ouro investido
	var refunded_gold: int = 0
	for def in UPGRADES_DEF:
		var u_id: String = def["id"]
		var lvl: int = save_system.candeeiro_upgrades.get(u_id, 0)
		for i in range(lvl):
			refunded_gold += def["base_cost"] * (i + 1)
		save_system.candeeiro_upgrades[u_id] = 0
		
	save_system.total_gold += refunded_gold
	save_system.save_game()
	_update_gold_display()
	_populate_upgrade_items()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/character_selection_menu.tscn")
