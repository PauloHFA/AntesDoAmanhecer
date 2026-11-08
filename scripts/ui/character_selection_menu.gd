class_name CharacterSelectionMenu
extends Control

## Tela de Seleção dos 6 Vigilantes (Seção 6, RF-11)
## Apresenta atributos, arquétipos e poderes antes de iniciar a partida.

@onready var class_list_container: HBoxContainer = $VBoxContainer/ClassListContainer
@onready var name_label: Label = $VBoxContainer/DetailPanel/VBox/NameLabel
@onready var archetype_label: Label = $VBoxContainer/DetailPanel/VBox/ArchetypeLabel
@onready var stats_label: Label = $VBoxContainer/DetailPanel/VBox/StatsLabel
@onready var special_label: Label = $VBoxContainer/DetailPanel/VBox/SpecialLabel
@onready var passive_label: Label = $VBoxContainer/DetailPanel/VBox/PassiveLabel
@onready var start_button: Button = $VBoxContainer/StartButton

const CLASS_RESOURCES: Array[String] = [
	"res://data/classes/benzedeira.tres",
	"res://data/classes/cangaceiro.tres",
	"res://data/classes/capoeirista.tres",
	"res://data/classes/ferreiro.tres",
	"res://data/classes/violeiro.tres",
	"data/classes/coveiro.tres"
]

var loaded_classes: Array[CharacterClassData] = []
var selected_class: CharacterClassData = null

func _ready() -> void:
	_load_class_data()
	_populate_buttons()
	if start_button:
		start_button.pressed.connect(_on_start_pressed)

func _load_class_data() -> void:
	loaded_classes.clear()
	var paths: Array[String] = [
		"res://data/classes/benzedeira.tres",
		"res://data/classes/cangaceiro.tres",
		"res://data/classes/capoeirista.tres",
		"res://data/classes/ferreiro.tres",
		"res://data/classes/violeiro.tres",
		"res://data/classes/coveiro.tres"
	]
	for p in paths:
		if ResourceLoader.exists(p):
			var res: CharacterClassData = load(p) as CharacterClassData
			if res:
				loaded_classes.append(res)
				
	if loaded_classes.size() > 0:
		_select_class(loaded_classes[0])

func _populate_buttons() -> void:
	if not class_list_container:
		return
	for c in loaded_classes:
		var btn: Button = Button.new()
		btn.text = c.display_name
		btn.custom_minimum_size = Vector2(90, 36)
		btn.pressed.connect(func() -> void: _select_class(c))
		class_list_container.add_child(btn)

func _select_class(c: CharacterClassData) -> void:
	selected_class = c
	if name_label: name_label.text = c.display_name
	if archetype_label: archetype_label.text = "Arquétipo: %s" % c.archetype
	if stats_label:
		stats_label.text = "Vida: %.0f%% | Velocidade: %.0f%% | Dano: %.0f%%" % [
			c.health_percent, c.speed_percent, c.damage_percent
		]
	if special_label:
		special_label.text = "Especial (Fúria): %s - %s" % [c.special_name, c.special_description]
	if passive_label:
		passive_label.text = "Passiva da Classe: %s" % c.passive_description

func _on_start_pressed() -> void:
	# Transiciona para a partida principal
	get_tree().change_scene_to_file("res://scenes/partida/partida_teste.tscn")
