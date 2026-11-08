class_name TestXPProgression
extends RefCounted

## Testes unitários para a curva de progressão de XP definida na Seção 5.2 do GDD:
## xp_necessario(n) = round(10 + 6*n + 0.35*n*n)

static func calculate_required_xp(level: int) -> int:
	var n: float = float(level)
	return int(round(10.0 + (6.0 * n) + (0.35 * n * n)))

static func run_all_tests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(test_level_1_xp())
	results.append(test_level_2_xp())
	results.append(test_level_10_xp())
	results.append(test_monotonic_growth())
	return results

static func test_level_1_xp() -> Dictionary:
	var xp: int = calculate_required_xp(1)
	# 10 + 6(1) + 0.35(1) = 16.35 -> round = 16
	var passed: bool = (xp == 16)
	return {
		"name": "Progressão: XP necessário para nível 1 é 16",
		"passed": passed,
		"details": "Calculado: %d (esperado: 16)" % xp
	}

static func test_level_2_xp() -> Dictionary:
	var xp: int = calculate_required_xp(2)
	# 10 + 6(2) + 0.35(4) = 10 + 12 + 1.4 = 23.4 -> round = 23
	var passed: bool = (xp == 23)
	return {
		"name": "Progressão: XP necessário para nível 2 é 23",
		"passed": passed,
		"details": "Calculado: %d (esperado: 23)" % xp
	}

static func test_level_10_xp() -> Dictionary:
	var xp: int = calculate_required_xp(10)
	# 10 + 6(10) + 0.35(100) = 10 + 60 + 35 = 105
	var passed: bool = (xp == 105)
	return {
		"name": "Progressão: XP necessário para nível 10 é 105",
		"passed": passed,
		"details": "Calculado: %d (esperado: 105)" % xp
	}

static func test_monotonic_growth() -> Dictionary:
	var strictly_increasing: bool = true
	var previous_xp: int = calculate_required_xp(1)
	
	for lvl in range(2, 51):
		var current_xp: int = calculate_required_xp(lvl)
		if current_xp <= previous_xp:
			strictly_increasing = false
			break
		previous_xp = current_xp
		
	return {
		"name": "Progressão: Curva de XP é estritamente crescente até nível 50",
		"passed": strictly_increasing,
		"details": "Crescimento contínuo verificado" if strictly_increasing else "Falha de monotonia"
	}
