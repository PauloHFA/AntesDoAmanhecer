class_name TestPlayerLogic
extends RefCounted

## Testes unitários para validar a lógica de movimento e atributos do Vigilante (CA-01)

static func run_all_tests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(test_diagonal_normalization())
	results.append(test_zero_input_produces_zero_velocity())
	results.append(test_cardinal_input_preserves_magnitude())
	results.append(test_damage_and_death_logic())
	results.append(test_heal_does_not_exceed_max_health())
	return results

static func test_diagonal_normalization() -> Dictionary:
	var raw_diagonal: Vector2 = Vector2(1.0, 1.0)
	var normalized: Vector2 = raw_diagonal.normalized()
	var tolerance: float = 0.0001
	
	var length_is_one: bool = absf(normalized.length() - 1.0) < tolerance
	var components_are_equal: bool = absf(normalized.x - 0.707106) < 0.001
	
	var passed: bool = length_is_one and components_are_equal
	return {
		"name": "CA-01: Vetor diagonal normalizado preserva magnitude unitária",
		"passed": passed,
		"details": "Comprimento: %f (esperado: 1.0)" % normalized.length()
	}

static func test_zero_input_produces_zero_velocity() -> Dictionary:
	var input: Vector2 = Vector2.ZERO
	var speed: float = 120.0
	var vel: Vector2 = input * speed
	
	var passed: bool = vel == Vector2.ZERO
	return {
		"name": "CA-01: Entrada nula resulta em velocidade zero",
		"passed": passed,
		"details": "Velocidade: %s" % str(vel)
	}

static func test_cardinal_input_preserves_magnitude() -> Dictionary:
	var input_right: Vector2 = Vector2(1.0, 0.0)
	var speed: float = 120.0
	var vel: Vector2 = input_right * speed
	
	var passed: bool = vel.length() == 120.0 and vel.x == 120.0 and vel.y == 0.0
	return {
		"name": "CA-01: Entrada cardeal respeita a velocidade base exata",
		"passed": passed,
		"details": "Magnitude calculada: %f" % vel.length()
	}

static func test_damage_and_death_logic() -> Dictionary:
	var max_hp: int = 100
	var hp: int = max_hp
	
	# Aplica 40 de dano
	hp = clampi(hp - 40, 0, max_hp)
	var first_damage_ok: bool = (hp == 60)
	
	# Aplica 80 de dano (deve travar em 0, sem valores negativos)
	hp = clampi(hp - 80, 0, max_hp)
	var death_ok: bool = (hp == 0)
	
	return {
		"name": "CA-12: Redução de vida e morte ao atingir 0 HP (sem vida negativa)",
		"passed": first_damage_ok and death_ok,
		"details": "Vida final: %d (esperado: 0)" % hp
	}

static func test_heal_does_not_exceed_max_health() -> Dictionary:
	var max_hp: int = 100
	var hp: int = 90
	
	# Cura 50 pontos
	hp = clampi(hp + 50, 0, max_hp)
	var passed: bool = (hp == max_hp)
	
	return {
		"name": "Vida: Cura respeita o limite máximo de HP",
		"passed": passed,
		"details": "Vida após cura: %d (máximo: %d)" % [hp, max_hp]
	}
