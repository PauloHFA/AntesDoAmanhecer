class_name SpatialHashGrid
extends RefCounted

## Grade Espacial (Spatial Hash Grid) de Alto Desempenho (T3, Seção 12.2)
## Divide o mundo 2D em células regulares para busca espacial em O(1) médio.
## Projetada para suportar 1.000 a 3.000 entidades com alocação zero de strings.

var cell_size: float = 64.0
var inv_cell_size: float = 1.0 / 64.0

# Dicionário de células: chave inteira (32-bit hash) -> PackedInt32Array de IDs
var cells: Dictionary = {}

func _init(initial_cell_size: float = 64.0) -> void:
	cell_size = maxf(initial_cell_size, 16.0)
	inv_cell_size = 1.0 / cell_size

## Limpa a grade para o próximo quadro de simulação
func clear() -> void:
	cells.clear()

## Calcula a chave inteira única para uma célula (cx, cy) sem gerar strings
func get_cell_key(x: int, y: int) -> int:
	return (x & 0xFFFF) | ((y & 0xFFFF) << 16)

## Insere uma entidade na grade com base na sua posição global
func insert(entity_id: int, pos: Vector2) -> void:
	var cx: int = int(floor(pos.x * inv_cell_size))
	var cy: int = int(floor(pos.y * inv_cell_size))
	var key: int = get_cell_key(cx, cy)
	
	if not cells.has(key):
		cells[key] = PackedInt32Array([entity_id])
	else:
		cells[key].append(entity_id)

## Retorna todos os IDs de entidades dentro do raio especificado
func query_radius(center: Vector2, radius: float, positions: PackedVector2Array) -> PackedInt32Array:
	var result: PackedInt32Array = PackedInt32Array()
	var radius_sq: float = radius * radius
	
	var min_cx: int = int(floor((center.x - radius) * inv_cell_size))
	var max_cx: int = int(floor((center.x + radius) * inv_cell_size))
	var min_cy: int = int(floor((center.y - radius) * inv_cell_size))
	var max_cy: int = int(floor((center.y + radius) * inv_cell_size))
	
	for cx in range(min_cx, max_cx + 1):
		for cy in range(min_cy, max_cy + 1):
			var key: int = get_cell_key(cx, cy)
			if cells.has(key):
				var cell_entities: PackedInt32Array = cells[key]
				for i in range(cell_entities.size()):
					var id: int = cell_entities[i]
					if id >= 0 and id < positions.size():
						if center.distance_squared_to(positions[id]) <= radius_sq:
							result.append(id)
							
	return result

## Retorna vizinhos imediatos em uma célula para separação/repulsão leve
func get_cell_entities(cx: int, cy: int) -> PackedInt32Array:
	var key: int = get_cell_key(cx, cy)
	if cells.has(key):
		return cells[key]
	return PackedInt32Array()
