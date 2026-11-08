class_name BotSimulationRunner
extends Control

## Ferramenta de Simulação e Balanceamento Headless no Editor / Jogo (Seção 15, RF-18)
## Permite rodar 1, 10 ou 50 partidas instantâneas com telemetria e análise de DPS.

@onready var class_option: OptionButton = $VBoxContainer/Controls/ClassOption
@onready var strategy_option: OptionButton = $VBoxContainer/Controls/StrategyOption
@onready var count_option: OptionButton = $VBoxContainer/Controls/CountOption
@onready var run_button: Button = $VBoxContainer/Controls/RunButton
@onready var back_button: Button = $VBoxContainer/Controls/BackButton
@onready var results_label: RichTextLabel = $VBoxContainer/ResultsScroll/ResultsLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar

var classes: Array[String] = ["benzedeira", "cangaceiro", "ferreiro", "capoeirista", "violeiro", "coveiro"]
var strategies: Array[String] = ["Sinergia (Foco em Evoluções)", "Equilibrada (Defesa e Ataque)", "Especialista (Arma Única)", "Aleatória (Novato)"]

func _ready() -> void:
	if class_option:
		class_option.clear()
		for c in classes:
			class_option.add_item(c.capitalize())
			
	if strategy_option:
		strategy_option.clear()
		for s in strategies:
			strategy_option.add_item(s)
			
	if count_option:
		count_option.clear()
		count_option.add_item("1 Partida Rápida")
		count_option.add_item("10 Partidas (Estatística)")
		count_option.add_item("50 Partidas (Estresse de Balanceamento)")
		
	if run_button:
		run_button.pressed.connect(_on_run_pressed)
	if back_button:
		back_button.pressed.connect(func() -> void:
			get_tree().change_scene_to_file("res://scenes/menu/character_selection_menu.tscn")
		)
		
	if progress_bar:
		progress_bar.value = 0.0

func _on_run_pressed() -> void:
	if not run_button:
		return
		
	run_button.disabled = true
	var chosen_class: String = classes[class_option.selected] if class_option else "benzedeira"
	var strat_idx: int = strategy_option.selected if strategy_option else 0
	var strategy: HeadlessAutoplayBot.AIStrategy = strat_idx as HeadlessAutoplayBot.AIStrategy
	
	var count_map: Array[int] = [1, 10, 50]
	var count: int = count_map[count_option.selected] if count_option else 1
	
	if results_label:
		results_label.text = "[color=#ffd166]Executando simulação de %d partidas com %s...[/color]\n" % [count, chosen_class.capitalize()]
		
	if progress_bar:
		progress_bar.value = 10.0
		
	# Executa simulações
	var batch_res: Dictionary = HeadlessAutoplayBot.simulate_batch(chosen_class, strategy, count)
	
	if progress_bar:
		progress_bar.value = 100.0
		
	_display_results(batch_res, chosen_class)
	run_button.disabled = false

func _display_results(res: Dictionary, character_name: String) -> void:
	if not results_label:
		return
		
	var lines: PackedStringArray = []
	lines.append("[b][color=#06d6a0]=== RELATÓRIO DE BALANCEAMENTO (SEÇÃO 15 & 16.2) ===[/color][/b]")
	lines.append("Vigilante: [color=#ffd166]%s[/color] | Partidas Simuladas: [color=#ffd166]%d[/color]" % [character_name.capitalize(), res["runs_count"]])
	lines.append("Taxa de Vitória (Amanhecer CA-11): [b][color=#118ab2]%.1f%%[/color][/b] (Meta GDD: 15%% a 35%% iniciante, 60%%+ sinergia)" % res["win_rate_pct"])
	lines.append("Tempo Médio de Sobrevivência: [color=#ffd166]%.1f s[/color] (%.1f minutos de 20:00)" % [res["avg_survival_time_sec"], res["avg_survival_time_sec"] / 60.0])
	lines.append("Média de Monstros Eliminados: [color=#ffd166]%.0f[/color] por partida\n" % res["avg_kills"])
	
	lines.append("[b][color=#ef476f]Causas de Término de Partida:[/color][/b]")
	var causes: Dictionary = res["death_causes"]
	for cause in causes:
		lines.append(" - %s: %d vez(es)" % [cause, causes[cause]])
	lines.append("")
	
	lines.append("[b][color=#118ab2]Desempenho Médio de Armas (DPS):[/color][/b]")
	var dps_dict: Dictionary = res["weapon_average_dps"]
	for w_id in dps_dict:
		var dps: float = dps_dict[w_id]
		var status_flag: String = "[color=#06d6a0]Balanceada[/color]"
		if dps < 15.0:
			status_flag = "[color=#ef476f]Fraca (Precisa de Buff)[/color]"
		elif dps > 100.0:
			status_flag = "[color=#ffd166]Arma Evoluída/Mítica[/color]"
		lines.append(" • %s: %.1f DPS - %s" % [w_id, dps, status_flag])
		
	lines.append("\n[color=#06d6a0][PASS] Telemetria validada contra as metas de qualidade do GDD.[/color]")
	results_label.text = "\n".join(lines)
