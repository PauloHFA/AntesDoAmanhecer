class_name MainMenu
extends Control

## Menu Principal de "Antes do Amanhecer" (M5 Lançamento, Seção 11.1)
## Ponto de entrada do jogo com navegação para seleção de personagens, loja, grimório e opções.

@onready var play_button: Button = $VBoxContainer/ButtonsVBox/PlayButton
@onready var candeeiro_button: Button = $VBoxContainer/ButtonsVBox/CandeeiroButton
@onready var grimoire_button: Button = $VBoxContainer/ButtonsVBox/GrimoireButton
@onready var options_button: Button = $VBoxContainer/ButtonsVBox/OptionsButton
@onready var quit_button: Button = $VBoxContainer/ButtonsVBox/QuitButton
@onready var version_label: Label = $VersionLabel

func _ready() -> void:
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if candeeiro_button:
		candeeiro_button.pressed.connect(func() -> void:
			get_tree().change_scene_to_file("res://scenes/menu/candeeiro_store.tscn")
		)
	if grimoire_button:
		grimoire_button.pressed.connect(func() -> void:
			get_tree().change_scene_to_file("res://scenes/menu/grimoire_menu.tscn")
		)
	if options_button:
		options_button.pressed.connect(func() -> void:
			get_tree().change_scene_to_file("res://scenes/menu/options_menu.tscn")
		)
	if quit_button:
		quit_button.pressed.connect(func() -> void:
			get_tree().quit()
		)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/character_selection_menu.tscn")
