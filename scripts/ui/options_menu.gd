class_name OptionsMenu
extends Control

## Menu de Opções e Acessibilidade (RNF-05, CA-15, Seção 10.3)
## Permite calibrar áudio, sensibilidade a flashes, tremor de tela e idioma.

@onready var shake_slider: HSlider = $VBoxContainer/ScrollContainer/VBox/ShakeRow/ShakeSlider
@onready var shake_value_lbl: Label = $VBoxContainer/ScrollContainer/VBox/ShakeRow/ShakeValueLabel
@onready var hitstop_check: CheckBox = $VBoxContainer/ScrollContainer/VBox/HitstopRow/HitstopCheck
@onready var numbers_check: CheckBox = $VBoxContainer/ScrollContainer/VBox/NumbersRow/NumbersCheck
@onready var photo_check: CheckBox = $VBoxContainer/ScrollContainer/VBox/PhotoRow/PhotoCheck
@onready var milestone_check: CheckBox = $VBoxContainer/ScrollContainer/VBox/MilestoneRow/MilestoneCheck

@onready var master_slider: HSlider = $VBoxContainer/ScrollContainer/VBox/MasterRow/MasterSlider
@onready var back_button: Button = $VBoxContainer/BackButton

var settings: SettingsManager = null

func _ready() -> void:
	var s_nodes: Array[Node] = get_tree().get_nodes_in_group("settings")
	if s_nodes.size() > 0:
		settings = s_nodes[0] as SettingsManager
		
	_sync_ui_with_settings()
	
	if shake_slider:
		shake_slider.value_changed.connect(_on_shake_changed)
	if hitstop_check:
		hitstop_check.toggled.connect(_on_hitstop_toggled)
	if numbers_check:
		numbers_check.toggled.connect(_on_numbers_toggled)
	if photo_check:
		photo_check.toggled.connect(_on_photo_toggled)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _sync_ui_with_settings() -> void:
	if not settings:
		return
	if shake_slider:
		shake_slider.value = settings.screen_shake_intensity * 100.0
		_update_shake_label(settings.screen_shake_intensity * 100.0)
	if hitstop_check:
		hitstop_check.button_pressed = settings.hit_stop_enabled
	if numbers_check:
		numbers_check.button_pressed = settings.damage_numbers_enabled
	if photo_check:
		photo_check.button_pressed = settings.photosensitivity_mode

func _on_shake_changed(val: float) -> void:
	_update_shake_label(val)
	if settings:
		settings.set_screen_shake(val / 100.0)

func _update_shake_label(val: float) -> void:
	if shake_value_lbl:
		shake_value_lbl.text = "%.0f%%" % val

func _on_hitstop_toggled(btn_pressed: bool) -> void:
	if settings:
		settings.set_hit_stop(btn_pressed)

func _on_numbers_toggled(btn_pressed: bool) -> void:
	if settings:
		settings.set_damage_numbers(btn_pressed)

func _on_photo_toggled(btn_pressed: bool) -> void:
	if settings:
		settings.photosensitivity_mode = btn_pressed

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/character_selection_menu.tscn")
