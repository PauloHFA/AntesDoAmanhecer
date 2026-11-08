class_name GrimoireMenu
extends Control

## Enciclopédia de Descobertas: O Grimório (RF-10, CA-08, Seção 5.4, Seção 9)
## Exibe coleção silhuetada (???) e percentual total de conclusão do jogo.

@onready var completion_label: Label = $VBoxContainer/TopBar/CompletionLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/TopBar/ProgressBar
@onready var entries_container: VBoxContainer = $VBoxContainer/ScrollContainer/EntriesContainer
@onready var back_button: Button = $VBoxContainer/BackButton

var save_system: SaveSystem = null

const GRIMOIRE_ENTRIES: Array[Dictionary] = [
	# Armas Básicas
	{ "id": "galho_arruda", "category": "Arma", "name": "Galho de Arruda", "desc": "Arma orbital de proteção e purificação contra o mal." },
	{ "id": "garrucha", "category": "Arma", "name": "Garrucha", "desc": "Arma de fogo do sertão com disparos perfurantes de alta precisão." },
	{ "id": "facao", "category": "Arma", "name": "Facão", "desc": "Lâmina afiada para cortar mata e criaturas em arco frontal." },
	{ "id": "fogo_fatuo", "category": "Arma", "name": "Fogo-Fátuo", "desc": "Chamas azuis que flutuam e perseguem almas errantes." },
	{ "id": "sino", "category": "Arma", "name": "Sino da Capela", "desc": "Pulso sagrado que ecoa pela noite expulsando o terror." },
	
	# Evoluções
	{ "id": "coroa_arruda", "category": "Evolução", "name": "Coroa de Arruda", "desc": "Dois anéis orbitais sagrados com aura de cura contínua." },
	{ "id": "trovao_sertao", "category": "Evolução", "name": "Trovão do Sertão", "desc": "Disparos duplos em leque com poder de atravessar montanhas." },
	{ "id": "boitata", "category": "Evolução", "name": "Boitatá", "desc": "A lendária serpente de chamas que incinera o campo de visão." },
	{ "id": "facao_furioso", "category": "Evolução", "name": "Facão Furioso", "desc": "Giro tempestuoso de lâminas em 360 graus." },
	{ "id": "repique_final", "category": "Evolução", "name": "Repique Final", "desc": "Ressonância gélida que congela criaturas em bloco de gelo." },
	
	# Fusões Secretas
	{ "id": "aurora_rubra", "category": "Fusão Secreta", "name": "Aurora Rubra", "desc": "Sol flamejante que persegue o chefe mais poderoso." },
	{ "id": "tempestade_sertao", "category": "Fusão Secreta", "name": "Tempestade do Sertão", "desc": "Tiros congelantes com ricochete infinito entre os monstros." },
	{ "id": "bencao_total", "category": "Fusão Secreta", "name": "Bênção Total", "desc": "Aura suprema que restaura o sobrevivente e desintegra as trevas." },
	
	# Bestiário
	{ "id": "alma_penada", "category": "Bestiário", "name": "Alma Penada", "desc": "Espírito corrompido que vaga na noite infinita." },
	{ "id": "mapinguari", "category": "Chefe", "name": "Mapinguari", "desc": "O gigante carnívoro de um só olho e boca no ventre." }
]

func _ready() -> void:
	save_system = SaveSystem.new()
	_populate_entries()
	if back_button:
		back_button.pressed.connect(func() -> void:
			get_tree().change_scene_to_file("res://scenes/menu/character_selection_menu.tscn")
		)

func _populate_entries() -> void:
	if not entries_container or not save_system:
		return
		
	for c in entries_container.get_children():
		c.queue_free()
		
	var unlocked_count: int = 0
	var total_count: int = GRIMOIRE_ENTRIES.size()
	
	for entry in GRIMOIRE_ENTRIES:
		var e_id: String = entry["id"]
		var is_unlocked: bool = save_system.grimoire_unlocked.has(e_id)
		if is_unlocked:
			unlocked_count += 1
			
		var row: PanelContainer = PanelContainer.new()
		row.custom_minimum_size = Vector2(0, 34)
		
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.theme_override_constants/separation = 12
		
		# Categoria
		var cat_lbl: Label = Label.new()
		cat_lbl.custom_minimum_size = Vector2(90, 0)
		cat_lbl.text = "[%s]" % entry["category"]
		cat_lbl.theme_override_font_sizes/font_size = 9
		cat_lbl.theme_override_colors/font_color = Color(0.4, 0.8, 1.0)
		hbox.add_child(cat_lbl)
		
		# Nome
		var name_lbl: Label = Label.new()
		name_lbl.custom_minimum_size = Vector2(140, 0)
		name_lbl.theme_override_font_sizes/font_size = 10
		
		# Descrição
		var desc_lbl: Label = Label.new()
		desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		desc_lbl.theme_override_font_sizes/font_size = 9
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		if is_unlocked:
			name_lbl.text = entry["name"]
			name_lbl.theme_override_colors/font_color = Color(1.0, 0.9, 0.4)
			desc_lbl.text = entry["desc"]
			desc_lbl.theme_override_colors/font_color = Color(0.8, 0.85, 0.9)
		else:
			name_lbl.text = "??? (Não Revelado)"
			name_lbl.theme_override_colors/font_color = Color(0.5, 0.5, 0.5)
			desc_lbl.text = "Descubra e experimente durante as noites para revelar sua história."
			desc_lbl.theme_override_colors/font_color = Color(0.4, 0.45, 0.5)
			
		hbox.add_child(name_lbl)
		hbox.add_child(desc_lbl)
		row.add_child(hbox)
		entries_container.add_child(row)
		
	var percent: float = (float(unlocked_count) / float(total_count)) * 100.0
	if completion_label:
		completion_label.text = "Progresso da Coleção: %d / %d (%.0f%%)" % [unlocked_count, total_count, percent]
	if progress_bar:
		progress_bar.max_value = total_count
		progress_bar.value = unlocked_count
