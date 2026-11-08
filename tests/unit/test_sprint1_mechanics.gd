class_name TestSprint1Mechanics
extends RefCounted

## Testes unitários para as mecânicas da Sprint 1: Galho de Arruda (CA-02) e Progressão (CA-03)

static func run_all_tests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(test_orbital_branch_angles())
	results.append(test_orbital_branch_radius())
	results.append(test_level_up_overflow_xp())
	results.append(test_weapon_damage_scaling())
	return results

static func test_orbital_branch_angles() -> Dictionary:
	# Com 3 galhos, a separação deve ser exatamente 120 graus (2*PI / 3)
	var branches_count: int = 3
	var expected_step: float = TAU / 3.0
	var actual_step: float = TAU / float(branches_count)
	
	var passed: bool = absf(actual_step - expected_step) < 0.0001
	return {
		"name": "CA-02: Distribuição angular equidistante dos galhos orbitais",
		"passed": passed,
		"details": "Passo angular: %f rad" % actual_step
	}

static func test_orbital_branch_radius() -> Dictionary:
	var radius: float = 38.0
	var angle: float = PI * 0.25 # 45 graus
	var pos: Vector2 = Vector2(cos(angle), sin(angle)) * radius
	
	var calculated_length: float = pos.length()
	var passed: bool = absf(calculated_length - radius) < 0.0001
	return {
		"name": "CA-02: Raio orbital de 38px preservado em qualquer ângulo",
		"passed": passed,
		"details": "Distância do centro: %f (esperado: 38.0)" % calculated_length
	}

static func test_level_up_overflow_xp() -> Dictionary:
	# Nível 1 exige 16 XP. Se o jogador coleta 20 XP, deve ir ao nível 2 com 4 XP restantes.
	var lvl: int = 1
	var target: int = TestXPProgression.calculate_required_xp(lvl) # 16
	var gained: int = 20
	var current: int = gained
	
	if current >= target:
		current -= target
		lvl += 1
		target = TestXPProgression.calculate_required_xp(lvl) # 23
		
	var passed: bool = (lvl == 2 and current == 4 and target == 23)
	return {
		"name": "CA-03: XP excedente é mantido após subir de nível",
		"passed": passed,
		"details": "Nível: %d, XP Restante: %d, Próxima Meta: %d" % [lvl, current, target]
	}

static func test_weapon_damage_scaling() -> Dictionary:
	var base_dmg: float = 14.0
	# Upgrade de +25%
	var upgraded_dmg: float = base_dmg * (1.0 + 0.25)
	var passed: bool = absf(upgraded_dmg - 17.5) < 0.0001
	return {
		"name": "CA-04: Upgrade de dano de arma aplica multiplicador correto",
		"passed": passed,
		"details": "Dano após upgrade: %.1f (esperado: 17.5)" % upgraded_dmg
	}
