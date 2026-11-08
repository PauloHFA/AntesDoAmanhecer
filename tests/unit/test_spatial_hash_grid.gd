class_name TestSpatialHashGrid
extends RefCounted

## Testes unitários para o SpatialHashGrid (T3, Seção 12.2)

static func run_all_tests() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	results.append(test_insert_and_query_exact())
	results.append(test_out_of_radius_exclusion())
	results.append(test_negative_coordinates())
	results.append(test_clear_resets_grid())
	return results

static func test_insert_and_query_exact() -> Dictionary:
	var grid: SpatialHashGrid = SpatialHashGrid.new(64.0)
	var positions: PackedVector2Array = PackedVector2Array([
		Vector2(100.0, 100.0),
		Vector2(500.0, 500.0)
	])
	
	grid.insert(0, positions[0])
	grid.insert(1, positions[1])
	
	var found: PackedInt32Array = grid.query_radius(Vector2(100.0, 100.0), 30.0, positions)
	var passed: bool = (found.size() == 1 and found[0] == 0)
	
	return {
		"name": "SpatialGrid: Retorna entidade exata dentro do raio de busca",
		"passed": passed,
		"details": "Encontrados: %s (esperado: [0])" % str(found)
	}

static func test_out_of_radius_exclusion() -> Dictionary:
	var grid: SpatialHashGrid = SpatialHashGrid.new(64.0)
	var positions: PackedVector2Array = PackedVector2Array([
		Vector2(100.0, 100.0)
	])
	grid.insert(0, positions[0])
	
	# Busca distante a 300px com raio 50
	var found: PackedInt32Array = grid.query_radius(Vector2(400.0, 400.0), 50.0, positions)
	var passed: bool = (found.size() == 0)
	
	return {
		"name": "SpatialGrid: Exclui corretamente entidades fora do raio",
		"passed": passed,
		"details": "Encontrados: %d (esperado: 0)" % found.size()
	}

static func test_negative_coordinates() -> Dictionary:
	var grid: SpatialHashGrid = SpatialHashGrid.new(64.0)
	var positions: PackedVector2Array = PackedVector2Array([
		Vector2(-120.0, -80.0),
		Vector2(-115.0, -75.0),
		Vector2(120.0, 80.0)
	])
	
	grid.insert(0, positions[0])
	grid.insert(1, positions[1])
	grid.insert(2, positions[2])
	
	var found: PackedInt32Array = grid.query_radius(Vector2(-120.0, -80.0), 25.0, positions)
	var passed: bool = (found.size() == 2 and found.has(0) and found.has(1))
	
	return {
		"name": "SpatialGrid: Opera perfeitamente com coordenadas negativas",
		"passed": passed,
		"details": "Encontrados no quadrante negativo: %s (esperado: [0, 1])" % str(found)
	}

static func test_clear_resets_grid() -> Dictionary:
	var grid: SpatialHashGrid = SpatialHashGrid.new(64.0)
	var positions: PackedVector2Array = PackedVector2Array([Vector2(0, 0)])
	grid.insert(0, positions[0])
	grid.clear()
	
	var found: PackedInt32Array = grid.query_radius(Vector2(0, 0), 50.0, positions)
	var passed: bool = (found.size() == 0)
	
	return {
		"name": "SpatialGrid: clear() limpa integralmente as células",
		"passed": passed,
		"details": "Contagem pós-clear: %d" % found.size()
	}
