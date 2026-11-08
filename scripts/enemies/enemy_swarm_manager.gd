class_name EnemySwarmManager
extends Node2D

## Gerenciador de Hordas em Lote de Alto Desempenho (T3, RNF-01, Seção 12.2)
## Simula até 2.000+ inimigos usando arrays contíguos de memória, MultiMeshInstance2D
## e SpatialHashGrid sem instanciar nós individuais para cada monstro.

@export var max_capacity: int = 2000
@export var cell_size: float = 64.0
@export var base_contact_damage: int = 8
@export var separation_radius: float = 12.0
@export var separation_strength: float = 35.0

# Arrays contíguos de alto desempenho
var positions: PackedVector2Array = PackedVector2Array()
var velocities: PackedVector2Array = PackedVector2Array()
var healths: PackedFloat32Array = PackedFloat32Array()
var max_healths: PackedFloat32Array = PackedFloat32Array()
var speeds: PackedFloat32Array = PackedFloat32Array()
var hit_flash_times: PackedFloat32Array = PackedFloat32Array()
var active_flags: Array[bool] = []
var free_slots: Array[int] = []

var active_count: int = 0
var spatial_grid: SpatialHashGrid = null
var multimesh: MultiMesh = null
var multimesh_instance: MultiMeshInstance2D = null

# Métricas de benchmark
var last_simulation_time_ms: float = 0.0
var player_ref: Node2D = null

const XP_GEM_SCENE: PackedScene = preload("res://scenes/pickups/xp_gem.tscn")

func _ready() -> void:
	add_to_group("swarm_manager")
	spatial_grid = SpatialHashGrid.new(cell_size)
	_setup_arrays()
	_setup_multimesh()
	_find_player()

func _setup_arrays() -> void:
	positions.resize(max_capacity)
	velocities.resize(max_capacity)
	healths.resize(max_capacity)
	max_healths.resize(max_capacity)
	speeds.resize(max_capacity)
	hit_flash_times.resize(max_capacity)
	active_flags.resize(max_capacity)
	free_slots.clear()
	
	for i in range(max_capacity):
		active_flags[i] = false
		positions[i] = Vector2(-99999.0, -99999.0)
		velocities[i] = Vector2.ZERO
		healths[i] = 0.0
		max_healths[i] = 0.0
		speeds[i] = 0.0
		hit_flash_times[i] = 0.0
		free_slots.append(i)

func _setup_multimesh() -> void:
	multimesh_instance = MultiMeshInstance2D.new()
	multimesh_instance.name = "SwarmMultiMesh"
	add_child(multimesh_instance)
	
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.use_colors = true
	multimesh.instance_count = max_capacity
	multimesh.visible_instance_count = max_capacity
	
	# Cria a malha retangular simples (quad) para cada instância de monstro
	var quad_mesh: QuadMesh = QuadMesh.new()
	quad_mesh.size = Vector2(14.0, 14.0)
	multimesh.mesh = quad_mesh
	multimesh_instance.multimesh = multimesh
	
	# Inicializa todas fora da tela
	var offscreen_xform: Transform2D = Transform2D(0.0, Vector2(-99999.0, -99999.0))
	for i in range(max_capacity):
		multimesh.set_instance_transform_2d(i, offscreen_xform)
		multimesh.set_instance_color(i, Color(0.45, 0.18, 0.55, 1.0))

func _physics_process(delta: float) -> void:
	if active_count == 0:
		return
		
	var start_usec: int = Time.get_ticks_usec()
	
	if not is_instance_valid(player_ref):
		_find_player()
		
	var player_pos: Vector2 = player_ref.global_position if is_instance_valid(player_ref) else Vector2.ZERO
	
	# 1. Limpa grade espacial
	spatial_grid.clear()
	
	# 2. Insere entidades ativas na grade
	for i in range(max_capacity):
		if active_flags[i]:
			spatial_grid.insert(i, positions[i])
			
	# 3. Atualiza posições, perseguição e repulsão
	var player_damage_radius_sq: float = 12.0 * 12.0
	var hit_player_this_frame: bool = false
	var separation_radius_sq: float = separation_radius * separation_radius
	
	for i in range(max_capacity):
		if not active_flags[i]:
			continue
			
		var pos: Vector2 = positions[i]
		var dir_to_player: Vector2 = (player_pos - pos).normalized()
		var spd: float = speeds[i]
		
		# Movimentação em direção ao jogador
		var move_vector: Vector2 = dir_to_player * spd * delta
		
		# Repulsão leve entre vizinhos da mesma célula para evitar aglomeração em ponto único
		var cx: int = int(floor(pos.x * spatial_grid.inv_cell_size))
		var cy: int = int(floor(pos.y * spatial_grid.inv_cell_size))
		var neighbors: PackedInt32Array = spatial_grid.get_cell_entities(cx, cy)
		
		var push_vector: Vector2 = Vector2.ZERO
		var neighbor_count: int = 0
		for n_idx in range(neighbors.size()):
			var neighbor_id: int = neighbors[n_idx]
			if neighbor_id != i and active_flags[neighbor_id]:
				var n_pos: Vector2 = positions[neighbor_id]
				var d_sq: float = pos.distance_squared_to(n_pos)
				if d_sq < separation_radius_sq and d_sq > 0.001:
					var dist: float = sqrt(d_sq)
					push_vector += (pos - n_pos) * ((separation_radius - dist) / separation_radius)
					neighbor_count += 1
					if neighbor_count >= 4:
						break
						
		if neighbor_count > 0:
			move_vector += push_vector * (separation_strength * delta)
			
		pos += move_vector
		positions[i] = pos
		
		# Checa dano ao jogador
		if not hit_player_this_frame and is_instance_valid(player_ref):
			if pos.distance_squared_to(player_pos) <= player_damage_radius_sq:
				if player_ref.has_method("take_damage"):
					player_ref.take_damage(base_contact_damage)
					hit_player_this_frame = true
					
		# Atualiza hit-flash
		var flash: float = hit_flash_times[i]
		if flash > 0.0:
			flash -= delta
			hit_flash_times[i] = maxf(flash, 0.0)
			
		# 4. Atualiza MultiMesh com animação procedural orgânica viva (Undulação, Flutuação e Squash no Dano)
		var facing_scale_x: float = -1.0 if dir_to_player.x < 0 else 1.0
		var t_anim: float = float(Time.get_ticks_msec()) * 0.009 + float(i) * 0.75
		var bob_offset: float = absf(sin(t_anim)) * 2.2
		var squish: float = 1.0 + sin(t_anim * 1.3) * 0.12
		var tilt: float = sin(t_anim * 0.8) * 0.08
		
		var scale_y: float = 1.0 / squish
		if flash > 0.0:
			# Deformação elástica de impacto
			squish = 1.35
			scale_y = 0.65
			
		var xform: Transform2D = Transform2D(tilt, Vector2(facing_scale_x * squish, scale_y), 0.0, Vector2(pos.x, pos.y - bob_offset))
		multimesh.set_instance_transform_2d(i, xform)
		
		if flash > 0.0:
			multimesh.set_instance_color(i, Color(2.8, 2.8, 2.8, 1.0)) # Flash branco puro
		else:
			# Variação procedural de matiz noturno folclórico
			var tint_type: int = i % 3
			if tint_type == 0:
				multimesh.set_instance_color(i, Color(0.48, 0.18, 0.58, 1.0)) # Violeta
			elif tint_type == 1:
				multimesh.set_instance_color(i, Color(0.28, 0.22, 0.64, 1.0)) # Anil espectral
			else:
				multimesh.set_instance_color(i, Color(0.38, 0.14, 0.46, 1.0)) # Sombra profunda
			
	var elapsed_usec: int = Time.get_ticks_usec() - start_usec
	last_simulation_time_ms = float(elapsed_usec) / 1000.0

## Gera um inimigo no lote usando um slot reciclado
func spawn_enemy(pos: Vector2, max_hp: float = 20.0, spd: float = 60.0) -> int:
	if free_slots.is_empty():
		return -1
		
	var idx: int = free_slots.pop_back()
	active_flags[idx] = true
	positions[idx] = pos
	velocities[idx] = Vector2.ZERO
	healths[idx] = max_hp
	max_healths[idx] = max_hp
	speeds[idx] = spd
	hit_flash_times[idx] = 0.0
	active_count += 1
	
	var xform: Transform2D = Transform2D(0.0, pos)
	multimesh.set_instance_transform_2d(idx, xform)
	multimesh.set_instance_color(idx, Color(0.45, 0.18, 0.55, 1.0))
	return idx

## Aplica dano a todas as entidades dentro do raio consultando a grade espacial (T3)
func damage_in_radius(center: Vector2, radius: float, damage: float, knockback: float = 0.0) -> int:
	if active_count == 0 or spatial_grid == null:
		return 0
		
	var targets: PackedInt32Array = spatial_grid.query_radius(center, radius, positions)
	var hits: int = 0
	
	for i in range(targets.size()):
		var idx: int = targets[i]
		if not active_flags[idx]:
			continue
			
		healths[idx] -= damage
		hit_flash_times[idx] = 0.08
		hits += 1
		
		if knockback > 0.0:
			var kb_dir: Vector2 = (positions[idx] - center).normalized()
			positions[idx] += kb_dir * knockback
			
		if healths[idx] <= 0.0:
			kill_enemy(idx, true)
			
	if hits > 0:
		var d_pools: Array[Node] = get_tree().get_nodes_in_group("damage_pool")
		if d_pools.size() > 0:
			var dmg_pool: DamageNumberPool = d_pools[0] as DamageNumberPool
			dmg_pool.spawn_number(center, damage)

	return hits

## Elimina um inimigo do lote e recicla seu slot
func kill_enemy(index: int, drop_gem: bool = true) -> void:
	if index < 0 or index >= max_capacity or not active_flags[index]:
		return
		
	var death_pos: Vector2 = positions[index]
	active_flags[index] = false
	active_count -= 1
	free_slots.append(index)
	
	# Move visual para fora da tela
	var offscreen: Transform2D = Transform2D(0.0, Vector2(-99999.0, -99999.0))
	multimesh.set_instance_transform_2d(index, offscreen)
	
	if has_node("/root/EventBus"):
		EventBus.enemy_killed.emit("Alma Penada (Lote)", death_pos, drop_gem)
		
	var fx_pools: Array[Node] = get_tree().get_nodes_in_group("death_fx_pool")
	if fx_pools.size() > 0:
		var death_fx: DeathParticlesPool = fx_pools[0] as DeathParticlesPool
		death_fx.spawn_death_burst(death_pos)

	if drop_gem and XP_GEM_SCENE:
		var gem: Node2D = XP_GEM_SCENE.instantiate() as Node2D
		gem.global_position = death_pos
		get_parent().call_deferred("add_child", gem)

func clear_all() -> void:
	for i in range(max_capacity):
		if active_flags[i]:
			kill_enemy(i, false)

func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as Node2D
