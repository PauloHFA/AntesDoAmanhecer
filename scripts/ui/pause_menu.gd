class_name PauseMenu
extends Control

## Menu de Pausa durante a Partida (Seção 11.1, CA-01 a CA-16)
## Executa com PROCESS_MODE_ALWAYS para responder quando a partida estiver pausada via ESC.

@onready var resume_btn: Button = $PanelContainer/VBox/Buttons/ResumeButton
@onready var restart_btn: Button = $PanelContainer/VBox/Buttons/RestartButton
@onready var options_btn: Button = $PanelContainer/VBox/Buttons/OptionsButton
@onready var menu_btn: Button = $PanelContainer/VBox/Buttons/MenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	if resume_btn:
		resume_btn.pressed.connect(resume_game)
	if restart_btn:
		restart_btn.pressed.connect(func() -> void:
			get_tree().paused = false
			get_tree().reload_current_scene()
		)
	if options_btn:
		options_btn.pressed.connect(func() -> void:
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/menu/options_menu.tscn")
		)
	if menu_btn:
		menu_btn.pressed.connect(func() -> void:
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
		)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			resume_game()
		else:
			pause_game()
		get_viewport().set_input_as_handled()

func pause_game() -> void:
	# Não abre o menu de pausa se houver level-up ou resumo de partida aberto
	var parent_layer: CanvasLayer = get_parent() as CanvasLayer
	if parent_layer:
		var levelup: Node = parent_layer.get_node_or_null("LevelUpMenu")
		var summary: Node = parent_layer.get_node_or_null("MatchSummaryModal")
		if (levelup and levelup.visible) or (summary and summary.visible):
			return
			
	visible = true
	get_tree().paused = true
	if has_node("/root/EventBus"):
		EventBus.game_paused.emit(true)

func resume_game() -> void:
	visible = false
	get_tree().paused = false
	if has_node("/root/EventBus"):
		EventBus.game_paused.emit(false)
