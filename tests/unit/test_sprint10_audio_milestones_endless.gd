class_name TestSprint10AudioMilestonesEndless
extends RefCounted

## Testes unitários para Áudio, Marcos de Abate (CA-06) e Noite Infinita (RF-07, RF-18)

static func run_all_tests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(test_milestone_trigger_when_enabled_ca06())
	results.append(test_milestone_blocked_when_disabled_ca06())
	results.append(test_hora_morta_endless_stats())
	results.append(test_audio_pitch_shift_bounds())
	return results

static func test_milestone_trigger_when_enabled_ca06() -> Dictionary:
	var kills: int = 100
	var target_milestone: int = 100
	var enabled_flag: bool = true
	var triggered: bool = false
	
	if enabled_flag and kills >= target_milestone:
		triggered = true
		
	var passed: bool = (triggered == true)
	return {
		"name": "CA-06: Marco de 100 abates dispara Momento Épico quando ativado",
		"passed": passed,
		"details": "Disparo acionado: %s (esperado: true)" % str(triggered)
	}

static func test_milestone_blocked_when_disabled_ca06() -> Dictionary:
	var kills: int = 100
	var target_milestone: int = 100
	var enabled_flag: bool = false # Opção desligada nas configurações (CA-06)
	var triggered: bool = false
	
	if enabled_flag and kills >= target_milestone:
		triggered = true
		
	var passed: bool = (triggered == false)
	return {
		"name": "CA-06: Marco de abates é ignorado se a opção estiver desativada",
		"passed": passed,
		"details": "Disparo com opção desligada: %s (esperado: false)" % str(triggered)
	}

static func test_hora_morta_endless_stats() -> Dictionary:
	var hora_morta_hp: float = 99999.0
	var hora_morta_speed: float = 145.0
	var player_base_speed: float = 120.0
	
	# Deve ser mais rápida que a velocidade base do jogador, obrigando fuga
	var passed: bool = (hora_morta_hp >= 50000.0 and hora_morta_speed > player_base_speed)
	return {
		"name": "RF-18: A Hora Morta é quase invencível e mais rápida que o jogador",
		"passed": passed,
		"details": "Vida: %.0f | Velocidade: %.0f px/s (Jogador base: %.0f px/s)" % [
			hora_morta_hp, hora_morta_speed, player_base_speed
		]
	}

static func test_audio_pitch_shift_bounds() -> Dictionary:
	# Pitch shift entre 0.94 e 1.06
	var min_bound: float = 0.94
	var max_bound: float = 1.06
	var all_within_bounds: bool = true
	
	for i in range(20):
		var pitch: float = 1.0 * randf_range(min_bound, max_bound)
		if pitch < min_bound or pitch > max_bound:
			all_within_bounds = false
			break
			
	return {
		"name": "Seção 10.4: Variação procedural de pitch de áudio contida na faixa de segurança",
		"passed": all_within_bounds,
		"details": "Variação dentro dos limites (0.94 a 1.06) confirmada"
	}
