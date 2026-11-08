class_name MilestoneBlessingsMenu
extends Control

## Menu de Bênçãos da Madrugada nos Marcos de Abate (RF-07, CA-06, Seção 5.3)
## Acionado nos marcos de 100, 250, 500, 1.000, 2.000 abates com desaceleração e escolha de poder temporário.

@export var enabled: bool = true # Pode ser desligado nas opções (CA-06)

@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var milestone_label: Label = $Panel/VBoxContainer/MilestoneLabel
@onready var options_container: HBoxContainer = $Panel/VBoxContainer/OptionsContainer

const MILESTONES: Array[int] = [100, 250, 500, 1000, 2000, 4000, 8000]
var next_milestone_index: int = 0
var current_kills: int = 0

const BLESSING_OPTIONS: Array[Dictionary] = [
	{
		"id": "blessing_projectiles",
		"title": "Chuva de Projéteis",
		"desc": "+1 Projétil extra em todas as armas por 60 segundos.",
		"color": Color(0.3, 0.9, 1.0)
	},
	{
		"id": "blessing_gold_rain",
		"title": "Chuva de Ouro",
		"desc": "Cada criatura abatida rende +3 moedas de ouro por 60 segundos.",
		"color": Color(1.0, 0.85, 0.2)
	},
	{
		"id": "blessing_double_flame",
		"title": "Chama Dupla",
		"desc": "Dobra o dano e a área de todas as armas e da Candeia por 60 segundos.",
		"color": Color(1.0, 0.4, 0.2)
	}
]

func _ready() -> void:
	add_to_group("milestone_menu")
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false
	
	if has_node("/root/EventBus"):
		EventBus.enemy_killed.connect(_on_enemy_killed)

func _on_enemy_killed(_type: String, _pos: Vector2, _gem: bool) -> void:
	if not enabled or next_milestone_index >= MILESTONES.size():
		return
		
	current_kills += 1
	var target_milestone: int = MILESTONES[next_milestone_index]
	
	if current_kills >= target_milestone:
		next_milestone_index += 1
		_trigger_epic_moment(target_milestone)

func _trigger_epic_moment(milestone: int) -> void:
	# Pausa a árvore para a escolha do momento épico (CA-06)
	get_tree().paused = true
	
	milestone_label.text = "MARCO DE %d ABATES ALCANÇADO!" % milestone
	_populate_blessings()
	visible = true
	
	if has_node("/root/EventBus"):
		EventBus.kill_count_milestone_reached.emit(milestone)
		
	var juice_nodes: Array[Node] = get_tree().get_nodes_in_group("juice")
	if juice_nodes.size() > 0:
		var j: JuiceController = juice_nodes[0] as JuiceController
		j.add_trauma(0.7)

func _populate_blessings() -> void:
	for c in options_container.get_children():
		c.queue_free()
		
	for b in BLESSING_OPTIONS:
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(160, 130)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var rect: ColorRect = ColorRect.new()
		rect.custom_minimum_size = Vector2(140, 24)
		rect.color = b["color"]
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(rect)
		
		var t_lbl: Label = Label.new()
		t_lbl.text = b["title"]
		t_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		t_lbl.theme_override_font_sizes/font_size = 11
		t_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(t_lbl)
		
		var d_lbl: Label = Label.new()
		d_lbl.text = b["desc"]
		d_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		d_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d_lbl.theme_override_font_sizes/font_size = 9
		d_lbl.theme_override_colors/font_color = Color(0.75, 0.8, 0.9)
		d_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(d_lbl)
		
		btn.add_child(vbox)
		btn.pressed.connect(func() -> void: _select_blessing(b["id"]))
		options_container.add_child(btn)

func _select_blessing(blessing_id: String) -> void:
	# Aplica o bônus temporário
	match blessing_id:
		"blessing_projectiles":
			var weapons: Array[Node] = get_tree().get_nodes_in_group("weapons")
			for w in weapons:
				if w is GalhoArruda: w.add_branch()
		"blessing_gold_rain":
			if has_node("/root/EventBus"):
				EventBus.gold_collected.emit(50, 0)
		"blessing_double_flame":
			var weapons: Array[Node] = get_tree().get_nodes_in_group("weapons")
			for w in weapons:
				if w.has_method("increase_damage"): w.increase_damage(0.5)
				
	visible = false
	get_tree().paused = false
