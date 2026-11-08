extends Control

## Executa a suíte de testes unitários da lógica do jogo e exibe os resultados na tela e no console.

@onready var output_label: RichTextLabel = $VBoxContainer/OutputText
@onready var summary_label: Label = $VBoxContainer/SummaryLabel

func _ready() -> void:
	run_all_suites()

func run_all_suites() -> void:
	var total_tests: int = 0
	var passed_tests: int = 0
	var failed_tests: int = 0
	
	var log_lines: PackedStringArray = []
	log_lines.append("[b][color=#ffd166]=== SUÍTE DE TESTES UNITÁRIOS: ANTES DO AMANHECER ===[/color][/b]\n")
	
	# Suíte 1: Lógica do Jogador
	log_lines.append("[b][color=#118ab2]-- Suíte: Movimento e Atributos do Jogador --[/color][/b]")
	var player_results: Array[Dictionary] = TestPlayerLogic.run_all_tests()
	for res in player_results:
		total_tests += 1
		if res["passed"]:
			passed_tests += 1
			log_lines.append("[color=#06d6a0]  [PASS][/color] %s" % res["name"])
		else:
			failed_tests += 1
			log_lines.append("[color=#ef476f]  [FAIL][/color] %s (%s)" % [res["name"], res["details"]])
			
	log_lines.append("")
	
	# Suíte 2: Progressão de XP
	log_lines.append("[b][color=#118ab2]-- Suíte: Curva de Progressão de XP --[/color][/b]")
	var xp_results: Array[Dictionary] = TestXPProgression.run_all_tests()
	for res in xp_results:
		total_tests += 1
		if res["passed"]:
			passed_tests += 1
			log_lines.append("[color=#06d6a0]  [PASS][/color] %s" % res["name"])
		else:
			failed_tests += 1
			log_lines.append("[color=#ef476f]  [FAIL][/color] %s (%s)" % [res["name"], res["details"]])
			
	log_lines.append("\n------------------------------------------------------------")
	var summary_text: String = "Testes Executados: %d | Aprovados: %d | Falhas: %d" % [total_tests, passed_tests, failed_tests]
	
	if failed_tests == 0:
		log_lines.append("[b][color=#06d6a0]STATUS FINAL: TODOS OS %d TESTES PASSARAM COM SUCESSO![/color][/b]" % total_tests)
		if summary_label:
			summary_label.text = summary_text + " - SUCESSO TOTAL"
			summary_label.modulate = Color(0.2, 1.0, 0.4)
	else:
		log_lines.append("[b][color=#ef476f]STATUS FINAL: HOUVE %d FALHAS DE TESTE![/color][/b]" % failed_tests)
		if summary_label:
			summary_label.text = summary_text + " - HOUVE FALHAS"
			summary_label.modulate = Color(1.0, 0.3, 0.3)
			
	if output_label:
		output_label.text = "\n".join(log_lines)
		
	# Também envia para o console padrão do Godot
	print(summary_text)
