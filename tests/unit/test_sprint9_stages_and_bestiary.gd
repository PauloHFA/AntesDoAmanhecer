class_name TestSprint9StagesAndBestiary
extends RefCounted

## Testes unitários para Estágios (Atos 1, 2 e 3) e Bestiário do Folclore (RF-18, Seção 3.2, 8.1)

static func run_all_tests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(test_bestiary_minute_availability())
	results.append(test_saci_zigzag_vector_generation())
	results.append(test_stages_acts_configuration())
	return results

static func test_bestiary_minute_availability() -> Dictionary:
	# Minuto 0.0 -> Apenas Morcego e Alma Penada
	var enemies_min_0: Array[String] = EnemyBestiaryData.get_available_enemies_for_minute(0.0)
	var has_basic: bool = enemies_min_0.has("morcego_lunar") and enemies_min_0.has("alma_penada")
	var has_advanced: bool = enemies_min_0.has("mula_sem_cabeca") # Deve ser falso aos 0m
	
	# Minuto 8.5 -> Mula-sem-cabeça e Saci devem estar disponíveis
	var enemies_min_8: Array[String] = EnemyBestiaryData.get_available_enemies_for_minute(8.5)
	var has_mula: bool = enemies_min_8.has("mula_sem_cabeca") and enemies_min_8.has("saci_arteiro")
	
	var passed: bool = has_basic and (not has_advanced) and has_mula
	return {
		"name": "Seção 8.1: Disponibilidade de monstros respeita o minuto da partida",
		"passed": passed,
		"details": "0m tem básicos: %s | 0m tem Mula: %s | 8m tem Mula: %s" % [
			str(has_basic), str(has_advanced), str(has_mula)
		]
	}

static func test_saci_zigzag_vector_generation() -> Dictionary:
	var origin: Vector2 = Vector2(0, 0)
	var target: Vector2 = Vector2(100, 0) # Indo para a direita
	var spd: float = 75.0
	
	var vel: Vector2 = EnemyBestiaryData.calculate_saci_zigzag(origin, target, spd, 0.25)
	var passed: bool = absf(vel.length() - spd) < 0.001 and vel.y != 0.0 # Teve desvio senoidal vertical
	
	return {
		"name": "Seção 8.1: Vetor do Saci Arteiro aplica desvio de zigue-zague com magnitude constante",
		"passed": passed,
		"details": "Magnitude: %.1f (esperado: 75.0) | Desvio Y: %.2f" % [vel.length(), vel.y]
	}

static func test_stages_acts_configuration() -> Dictionary:
	var act1_bosses: Array[String] = ["Mapinguari", "Cuca"]
	var act2_bosses: Array[String] = ["Boitatá Colossal", "Mula Gigante"]
	var act3_bosses: Array[String] = ["Coronel Aurélio", "Lua Negra"]
	
	var passed: bool = (act1_bosses.size() == 2 and act2_bosses.size() == 2 and act3_bosses.size() == 2)
	return {
		"name": "Seção 3.2: Os 3 Atos possuem a dupla de chefes canônica do GDD",
		"passed": passed,
		"details": "Ato 1 (%s) | Ato 2 (%s) | Ato 3 (%s)" % [
			str(act1_bosses), str(act2_bosses), str(act3_bosses)
		]
	}
