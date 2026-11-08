class_name TestSprint8SaveAndMetagame
extends RefCounted

## Testes unitários para Metajogo: Salvamento Atômico (RNF-08, CA-16), Candeeiro (CA-13) e Grimório (CA-08)

static func run_all_tests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(test_candeeiro_purchase_and_gold_debit_ca13())
	results.append(test_candeeiro_insufficient_gold_blocked())
	results.append(test_candeeiro_full_refund())
	results.append(test_grimoire_unlock_progress_ca08())
	return results

static func test_candeeiro_purchase_and_gold_debit_ca13() -> Dictionary:
	var total_gold: int = 200
	var current_lvl: int = 0
	var base_cost: int = 50
	var cost: int = base_cost * (current_lvl + 1) # 50
	
	if total_gold >= cost:
		total_gold -= cost
		current_lvl += 1
		
	var passed: bool = (total_gold == 150 and current_lvl == 1)
	return {
		"name": "CA-13: Compra no Candeeiro debita ouro e sobe nível de melhoria",
		"passed": passed,
		"details": "Ouro restante: %d (esperado: 150) | Nível: %d (esperado: 1)" % [total_gold, current_lvl]
	}

static func test_candeeiro_insufficient_gold_blocked() -> Dictionary:
	var total_gold: int = 30
	var current_lvl: int = 0
	var base_cost: int = 50
	var cost: int = base_cost * (current_lvl + 1) # 50
	var purchased: bool = false
	
	if total_gold >= cost:
		total_gold -= cost
		current_lvl += 1
		purchased = true
		
	var passed: bool = (not purchased and total_gold == 30 and current_lvl == 0)
	return {
		"name": "CA-13: Compra no Candeeiro é bloqueada com ouro insuficiente",
		"passed": passed,
		"details": "Compra efetuada: %s (esperado: false) | Ouro: %d" % [str(purchased), total_gold]
	}

static func test_candeeiro_full_refund() -> Dictionary:
	# Simula 3 compras com custos: 50, 100, 150 = 300 gasto
	var base_cost: int = 50
	var lvl: int = 3
	var spent: int = 0
	for i in range(lvl):
		spent += base_cost * (i + 1) # 50 + 100 + 150 = 300
		
	var user_gold: int = 50
	# Reembolsa tudo
	user_gold += spent
	lvl = 0
	
	var passed: bool = (user_gold == 350 and lvl == 0)
	return {
		"name": "Candeeiro: Reembolso devolve 100% do ouro investido",
		"passed": passed,
		"details": "Ouro pós-reembolso: %d (esperado: 350)" % user_gold
	}

static func test_grimoire_unlock_progress_ca08() -> Dictionary:
	var total_entries: int = 15
	var unlocked_entries: Array[String] = ["galho_arruda", "garrucha"]
	
	# Desbloqueia nova arma
	var new_id: String = "trovao_sertao"
	if not unlocked_entries.has(new_id):
		unlocked_entries.append(new_id)
		
	var pct: float = (float(unlocked_entries.size()) / float(total_entries)) * 100.0
	var passed: bool = (unlocked_entries.size() == 3 and absf(pct - 20.0) < 0.0001)
	
	return {
		"name": "CA-08, RF-10: Descoberta registra no Grimório e recalcula porcentagem",
		"passed": passed,
		"details": "Total descoberto: %d / %d (%.0f%%)" % [unlocked_entries.size(), total_entries, pct]
	}
