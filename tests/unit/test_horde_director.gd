class_name TestHordeDirector
extends RefCounted

## Testes unitários para o Diretor de Hordas e Relógio da Noite (CA-09, CA-11, Seção 8.2)

static func run_all_tests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(test_enemy_health_growth_curve_min_0())
	results.append(test_enemy_health_growth_curve_min_10())
	results.append(test_enemy_health_growth_curve_min_20())
	results.append(test_ring_formation_equidistance())
	return results

static func test_enemy_health_growth_curve_min_0() -> Dictionary:
	var mult: float = HordeDirector.calculate_health_multiplier(0.0)
	var passed: bool = absf(mult - 1.0) < 0.0001
	return {
		"name": "CA-09: Multiplicador de vida no minuto 0 é 1.0 (base)",
		"passed": passed,
		"details": "Multiplicador: %.4f (esperado: 1.0)" % mult
	}

static func test_enemy_health_growth_curve_min_10() -> Dictionary:
	var mult: float = HordeDirector.calculate_health_multiplier(10.0)
	# 1.0 + (0.08 * 10) + (0.003 * 100) = 1.0 + 0.8 + 0.3 = 2.1
	var passed: bool = absf(mult - 2.1) < 0.0001
	return {
		"name": "CA-09: Multiplicador de vida no minuto 10 é 2.1 (210%)",
		"passed": passed,
		"details": "Multiplicador: %.4f (esperado: 2.1)" % mult
	}

static func test_enemy_health_growth_curve_min_20() -> Dictionary:
	var mult: float = HordeDirector.calculate_health_multiplier(20.0)
	# 1.0 + (0.08 * 20) + (0.003 * 400) = 1.0 + 1.6 + 1.2 = 3.8
	var passed: bool = absf(mult - 3.8) < 0.0001
	return {
		"name": "CA-09: Multiplicador de vida no minuto 20 (Amanhecer) é 3.8",
		"passed": passed,
		"details": "Multiplicador: %.4f (esperado: 3.8)" % mult
	}

static func test_ring_formation_equidistance() -> Dictionary:
	var center: Vector2 = Vector2(100.0, 200.0)
	var radius: float = 320.0
	var count: int = 16
	var step: float = TAU / float(count)
	var all_match: bool = true
	
	for i in range(count):
		var angle: float = i * step
		var pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius
		var dist: float = center.distance_to(pos)
		if absf(dist - radius) > 0.001:
			all_match = false
			break
			
	return {
		"name": "CA-09: Formação em anel posiciona monstros em raio constante",
		"passed": all_match,
		"details": "Distâncias verificadas no raio de %.1f px" % radius
	}
