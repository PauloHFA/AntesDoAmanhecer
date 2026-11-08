class_name MatchSummaryModal
extends Control

## Modal de Resumo de Partida (Morte / Vitória ao Amanhecer) (CA-11, CA-12, Seção 11.2)
## Apresenta estatísticas da run, salva o ouro no Candeeiro e oferece navegação.

@onready var title_label: Label = $PanelContainer/VBox/TitleLabel
@onready var subtitle_label: Label = $PanelContainer/VBox/SubtitleLabel
@onready var stats_label: RichTextLabel = $PanelContainer/VBox/StatsLabel
@onready var gold_saved_label: Label = $PanelContainer/VBox/GoldSavedLabel
@onready var retry_button: Button = $PanelContainer/VBox/Buttons/RetryButton
@onready var candeeiro_button: Button = $PanelContainer/VBox/Buttons/CandeeiroButton
@onready var menu_button: Button = $PanelContainer/VBox/Buttons/MenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
	if retry_button:
		retry_button.pressed.connect(func() -> void:
			get_tree().paused = false
			get_tree().reload_current_scene()
		)
	if candeeiro_button:
		candeeiro_button.pressed.connect(func() -> void:
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/menu/candeeiro_store.tscn")
		)
	if menu_button:
		menu_button.pressed.connect(func() -> void:
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
		)

## Exibe o resumo ao morrer ou vencer (CA-11, CA-12)
func show_summary(is_victory: bool, elapsed_seconds: float, final_level: int, kills: int, gold_earned: int) -> void:
	get_tree().paused = true
	visible = true
	
	# Persiste o ouro coletado atomicamente no save (CA-12, CA-16)
	var save_sys: SaveSystem = SaveSystem.new()
	save_sys.add_gold(gold_earned)
	
	var mins: int = int(elapsed_seconds) / 60
	var secs: int = int(elapsed_seconds) % 60
	var time_formatted: String = "%02d:%02d" % [mins, secs]
	
	if is_victory:
		if title_label:
			title_label.text = "O SOL NASCEU! VITÓRIA!"
			title_label.modulate = Color(1.0, 0.9, 0.3) # Dourado alvorecer
		if subtitle_label:
			subtitle_label.text = "A maldição foi quebrada e o sertão viu a luz do novo dia."
	else:
		if title_label:
			title_label.text = "CANDEIA APAGADA (A NOITE VENCEU)"
			title_label.modulate = Color(1.0, 0.3, 0.3) # Vermelho sangue
		if subtitle_label:
			subtitle_label.text = "A escuridão sobrenatural engoliu a vila... mas o ouro permanece."
			
	if stats_label:
		var text: String = ""
		text += "• [color=#ffd166]Tempo Sobrevivido:[/color] %s\n" % time_formatted
		text += "• [color=#118ab2]Nível Alcançado:[/color] Nv. %d\n" % final_level
		text += "• [color=#ef476f]Criaturas Banidas:[/color] %d abates\n" % kills
		stats_label.text = text
		
	if gold_saved_label:
		gold_saved_label.text = "+%d Moedas de Ouro Salvas no Candeeiro (Saldo Atual: %d)" % [
			gold_earned, save_sys.total_gold
		]
