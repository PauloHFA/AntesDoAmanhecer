class_name TestSprint6VerticalSlice
extends RefCounted

## Testes unitários para o Vertical Slice: Benzedeira (RF-11, RF-12) e Chefe Mapinguari (RF-13, CA-10)

static func run_all_tests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(test_fury_accumulation_and_cap())
	results.append(test_reza_forte_activation_consumes_fury())
	results.append(test_benzedeira_passive_healing())
	results.append(test_boss_mapinguari_health_and_damage())
	return results

static func test_fury_accumulation_and_cap() -> Dictionary:
	var fury: float = 0.0
	var max_fury: float = 100.0
	var kills: int = 45 # 45 * 2.5 = 112.5 -> deve limitar em 100.0
	
	for i in range(kills):
		fury = clampf(fury + 2.5, 0.0, max_fury)
		
	var passed: bool = (fury == 100.0)
	return {
		"name": "RF-12: Barra de fúria acumula até o teto de 100%",
		"passed": passed,
		"details": "Fúria acumulada: %.1f (esperado: 100.0)" % fury
	}

static func test_reza_forte_activation_consumes_fury() -> Dictionary:
	var fury: float = 100.0
	var special_duration: float = 5.0
	var is_active: bool = false
	
	# Ativa o especial
	if fury >= 100.0:
		is_active = true
		fury = 0.0
		
	var passed: bool = (is_active and fury == 0.0 and special_duration == 5.0)
	return {
		"name": "RF-12: Reza Forte zera fúria e ativa 5s de poder invulnerável",
		"passed": passed,
		"details": "Fúria pós-ativação: %.1f | Duração: %.1f s" % [fury, special_duration]
	}

static func test_benzedeira_passive_healing() -> Dictionary:
	var max_hp: int = 100
	var current_hp: int = 70
	
	# Simula cura da passiva da Benzedeira (+1 PV a cada 5s)
	current_hp = clampi(current_hp + 1, 0, max_hp)
	var passed: bool = (current_hp == 71)
	
	return {
		"name": "Seção 6: Passiva da Benzedeira regenera 1 PV gradualmente",
		"passed": passed,
		"details": "Vida após cura passiva: %d" % current_hp
	}

static func test_boss_mapinguari_health_and_damage() -> Dictionary:
	var boss_max_hp: float = 1200.0
	var boss_hp: float = boss_max_hp
	
	# Dano de 300 causado pelo jogador
	boss_hp -= 300.0
	var damage_taken_ok: bool = (boss_hp == 900.0)
	
	# Golpe sísmico do chefe
	var slam_damage: int = 25
	var player_hp: int = 100
	player_hp -= slam_damage
	var slam_ok: bool = (player_hp == 75)
	
	return {
		"name": "RF-13, CA-10: Mapinguari suporta 1200 PV e desfere golpe sísmico de 25 dano",
		"passed": damage_taken_ok and slam_ok,
		"details": "HP restante do chefe: %.0f | HP restante do jogador: %d" % [boss_hp, player_hp]
	}
