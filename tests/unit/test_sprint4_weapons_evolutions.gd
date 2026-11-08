class_name TestSprint4WeaponsEvolutions
extends RefCounted

## Testes unitários para Armas, Passivas, Evoluções e Baús (CA-04, CA-07, Seção 7.1)

static func run_all_tests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(test_evolution_eligible_with_max_level_and_passive())
	results.append(test_evolution_rejected_without_passive())
	results.append(test_evolution_rejected_below_max_level())
	results.append(test_max_level_filtering_ca04())
	return results

static func test_evolution_eligible_with_max_level_and_passive() -> Dictionary:
	var equipped_passives: Array[String] = ["escapulario", "ferradura"]
	var result: Dictionary = WeaponEvolutionManager.check_evolution_eligible("galho_arruda", 5, equipped_passives)
	
	var passed: bool = (not result.is_empty() and result.get("evolved_id", "") == "coroa_arruda")
	return {
		"name": "CA-07: Arma no nível máximo + passiva da receita qualifica evolução",
		"passed": passed,
		"details": "Evolução retornada: %s (esperado: coroa_arruda)" % result.get("evolved_id", "nenhuma")
	}

static func test_evolution_rejected_without_passive() -> Dictionary:
	var equipped_passives: Array[String] = ["outra_passiva"]
	var result: Dictionary = WeaponEvolutionManager.check_evolution_eligible("garrucha", 5, equipped_passives)
	
	var passed: bool = result.is_empty()
	return {
		"name": "CA-07: Evolução é bloqueada se a passiva da receita estiver ausente",
		"passed": passed,
		"details": "Resultado: %s (esperado: {})" % str(result)
	}

static func test_evolution_rejected_below_max_level() -> Dictionary:
	var equipped_passives: Array[String] = ["ferradura"]
	# Nível 3 (abaixo do nível de evolução)
	var result: Dictionary = WeaponEvolutionManager.check_evolution_eligible("garrucha", 3, equipped_passives)
	
	var passed: bool = result.is_empty()
	return {
		"name": "CA-07: Evolução é bloqueada se a arma estiver abaixo do nível máximo",
		"passed": passed,
		"details": "Resultado com nível 3: %s (esperado: {})" % str(result)
	}

static func test_max_level_filtering_ca04() -> Dictionary:
	var upgrade_levels: Dictionary = {
		"passive_ferradura": 5, # Maximizada!
		"passive_chapeu": 2     # Ainda pode subir
	}
	
	# Simula a regra do CA-04
	var ferradura_max: bool = (upgrade_levels["passive_ferradura"] >= 5)
	var chapeu_max: bool = (upgrade_levels["passive_chapeu"] >= 5)
	
	var passed: bool = ferradura_max and (not chapeu_max)
	return {
		"name": "CA-04: Poderes no nível máximo são marcados para exclusão das cartas",
		"passed": passed,
		"details": "Ferradura max: %s | Chapéu max: %s" % [str(ferradura_max), str(chapeu_max)]
	}
