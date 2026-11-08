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
			
	log_lines.append("")

	# Suíte 3: Mecânicas da Sprint 1 (Galho de Arruda e Progressão)
	log_lines.append("[b][color=#118ab2]-- Suíte: Mecânicas da Sprint 1 (CA-02, CA-03) --[/color][/b]")
	var sprint1_results: Array[Dictionary] = TestSprint1Mechanics.run_all_tests()
	for res in sprint1_results:
		total_tests += 1
		if res["passed"]:
			passed_tests += 1
			log_lines.append("[color=#06d6a0]  [PASS][/color] %s" % res["name"])
		else:
			failed_tests += 1
			log_lines.append("[color=#ef476f]  [FAIL][/color] %s (%s)" % [res["name"], res["details"]])
			
	log_lines.append("")

	# Suíte 4: Grade Espacial (SpatialHashGrid - T3, Seção 12.2)
	log_lines.append("[b][color=#118ab2]-- Suíte: Grade Espacial (T3, CA-14) --[/color][/b]")
	var grid_results: Array[Dictionary] = TestSpatialHashGrid.run_all_tests()
	for res in grid_results:
		total_tests += 1
		if res["passed"]:
			passed_tests += 1
			log_lines.append("[color=#06d6a0]  [PASS][/color] %s" % res["name"])
		else:
			failed_tests += 1
			log_lines.append("[color=#ef476f]  [FAIL][/color] %s (%s)" % [res["name"], res["details"]])
			
	log_lines.append("")

	# Suíte 5: Diretor de Hordas e Curvas da Noite (CA-09, CA-11)
	log_lines.append("[b][color=#118ab2]-- Suíte: Diretor de Hordas e Noite (CA-09, CA-11) --[/color][/b]")
	var director_results: Array[Dictionary] = TestHordeDirector.run_all_tests()
	for res in director_results:
		total_tests += 1
		if res["passed"]:
			passed_tests += 1
			log_lines.append("[color=#06d6a0]  [PASS][/color] %s" % res["name"])
		else:
			failed_tests += 1
			log_lines.append("[color=#ef476f]  [FAIL][/color] %s (%s)" % [res["name"], res["details"]])
			
	log_lines.append("")

	# Suíte 6: Armas, Passivas e Evoluções em Baú (CA-04, CA-07)
	log_lines.append("[b][color=#118ab2]-- Suíte: Armas, Passivas e Evoluções (CA-04, CA-07) --[/color][/b]")
	var sprint4_results: Array[Dictionary] = TestSprint4WeaponsEvolutions.run_all_tests()
	for res in sprint4_results:
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
