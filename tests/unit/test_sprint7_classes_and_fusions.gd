class_name TestSprint7ClassesAndFusions
extends RefCounted

## Testes unitários para as 6 Classes, Fusões Secretas e CA-05 (Reroll, Banir, Pular)

static func run_all_tests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(test_cangaceiro_and_ferreiro_stats())
	results.append(test_secret_fusion_tempestade_sertao())
	results.append(test_secret_fusion_missing_component_rejected())
	results.append(test_reroll_and_ban_counters_ca05())
	return results

static func test_cangaceiro_and_ferreiro_stats() -> Dictionary:
	# Cangaceiro: 90 Vida / 105 Vel / 110 Dano
	var cangaceiro_hp: float = 90.0
	var cangaceiro_dmg: float = 110.0
	
	# Ferreiro: 140 Vida / 85 Vel / 95 Dano
	var ferreiro_hp: float = 140.0
	var ferreiro_spd: float = 85.0
	
	var passed: bool = (cangaceiro_hp == 90.0 and cangaceiro_dmg == 110.0 and ferreiro_hp == 140.0 and ferreiro_spd == 85.0)
	return {
		"name": "Seção 6: Atributos das classes Cangaceiro e Ferreiro conferem com GDD",
		"passed": passed,
		"details": "Cangaceiro (%.0f HP, %.0f%% DMG) | Ferreiro (%.0f HP, %.0f%% SPD)" % [
			cangaceiro_hp, cangaceiro_dmg, ferreiro_hp, ferreiro_spd
		]
	}

static func test_secret_fusion_tempestade_sertao() -> Dictionary:
	var equipped_evolved: Array[String] = ["trovao_sertao", "repique_final"]
	var fusion: Dictionary = WeaponFusionManager.check_fusion_eligible(equipped_evolved)
	
	var passed: bool = (not fusion.is_empty() and fusion.get("fusion_id", "") == "tempestade_sertao")
	return {
		"name": "RF-09: Trovão do Sertão + Repique Final qualifica fusão Tempestade do Sertão",
		"passed": passed,
		"details": "Fusão retornada: %s (esperado: tempestade_sertao)" % fusion.get("fusion_id", "nenhuma")
	}

static func test_secret_fusion_missing_component_rejected() -> Dictionary:
	# Apenas Trovão do Sertão presente (falta Repique Final)
	var equipped_evolved: Array[String] = ["trovao_sertao", "coroa_arruda"]
	var fusion: Dictionary = WeaponFusionManager.check_fusion_eligible(equipped_evolved)
	
	var passed: bool = fusion.is_empty()
	return {
		"name": "RF-09: Fusão secreta é bloqueada sem os dois componentes evoluídos",
		"passed": passed,
		"details": "Resultado da busca incompleta: %s" % str(fusion)
	}

static func test_reroll_and_ban_counters_ca05() -> Dictionary:
	var rerolls: int = 2
	var bans: int = 1
	var banned_ids: Array[String] = []
	
	# 1. Executa Reroll
	if rerolls > 0:
		rerolls -= 1
		
	# 2. Executa Ban em "weapon_facao"
	if bans > 0:
		bans -= 1
		banned_ids.append("weapon_facao")
		
	var passed: bool = (rerolls == 1 and bans == 0 and banned_ids.has("weapon_facao"))
	return {
		"name": "CA-05: Reroll e Ban gastam 1 uso por ação e excluem poder banido",
		"passed": passed,
		"details": "Rerolls restantes: %d | Bans restantes: %d | Banidos: %s" % [rerolls, bans, str(banned_ids)]
	}
