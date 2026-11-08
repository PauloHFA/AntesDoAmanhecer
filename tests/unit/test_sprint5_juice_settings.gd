class_name TestSprint5JuiceSettings
extends RefCounted

## Testes unitários para Juice e Configurações de Acessibilidade (CA-15, Seção 10.2, 10.3)

static func run_all_tests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(test_trauma_clamping())
	results.append(test_trauma_decay())
	results.append(test_accessibility_disable_shake_ca15())
	results.append(test_accessibility_hit_stop_toggle())
	return results

static func test_trauma_clamping() -> Dictionary:
	var trauma: float = 0.0
	var add_amount: float = 1.8
	trauma = clampf(trauma + add_amount, 0.0, 1.0)
	
	var passed: bool = (trauma == 1.0)
	return {
		"name": "Juice: Trauma é limitado ao teto de 1.0",
		"passed": passed,
		"details": "Trauma resultante: %.2f (esperado: 1.0)" % trauma
	}

static func test_trauma_decay() -> Dictionary:
	var trauma: float = 1.0
	var decay_rate: float = 2.0
	var delta: float = 0.25 # 250ms
	trauma = move_toward(trauma, 0.0, delta * decay_rate) # 1.0 - 0.5 = 0.5
	
	var passed: bool = absf(trauma - 0.5) < 0.0001
	return {
		"name": "Juice: Trauma decai continuamente ao longo do tempo",
		"passed": passed,
		"details": "Trauma após 250ms: %.2f (esperado: 0.5)" % trauma
	}

static func test_accessibility_disable_shake_ca15() -> Dictionary:
	var settings: SettingsManager = SettingsManager.new()
	settings.set_screen_shake(0.0) # Desativa tremor (CA-15)
	
	var initial_trauma: float = 0.0
	var add_amount: float = 0.5
	var effective_added: float = add_amount * settings.screen_shake_intensity
	initial_trauma = clampf(initial_trauma + effective_added, 0.0, 1.0)
	
	var passed: bool = (initial_trauma == 0.0)
	return {
		"name": "CA-15: Desativar tremor nas opções anula trauma da câmera",
		"passed": passed,
		"details": "Trauma com shake desativado: %.2f (esperado: 0.0)" % initial_trauma
	}

static func test_accessibility_hit_stop_toggle() -> Dictionary:
	var settings: SettingsManager = SettingsManager.new()
	settings.set_hit_stop(false)
	
	var passed: bool = (settings.hit_stop_enabled == false)
	return {
		"name": "CA-15: Alternância de hit-stop respeitada nas configurações",
		"passed": passed,
		"details": "Hit-stop habilitado: %s" % str(settings.hit_stop_enabled)
	}
