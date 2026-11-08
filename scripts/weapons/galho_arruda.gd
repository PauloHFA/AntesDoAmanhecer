class_name GalhoArruda
extends Node2D

## Arma Orbital: Galho de Arruda (Arma inicial da Benzedeira - Seção 7.1)
## Orbita ao redor do jogador, bloqueia projéteis e causa dano contínuo ao contato.

@export var base_damage: float = 14.0
@export var orbit_radius: float = 38.0
@export var orbit_speed: float = 3.6
@export var branches_count: int = 1
@export var damage_interval: float = 0.4

var current_angle: float = 0.0
var branch_nodes: Array[Area2D] = []
var enemy_damage_cooldowns: Dictionary = {} # Enemy instance_id -> float timestamp
var swarm_tick_timer: float = 0.0

func _ready() -> void:
	add_to_group("weapons")
	rebuild_branches()

func _physics_process(delta: float) -> void:
	current_angle += orbit_speed * delta
	if current_angle > TAU:
		current_angle -= TAU
		
	# Atualiza a posição de cada ramo orbital com ondulação elíptica viva
	var step_angle: float = TAU / float(maxi(branches_count, 1))
	for i in range(branch_nodes.size()):
		var angle: float = current_angle + (i * step_angle)
		var wobble: float = sin(current_angle * 2.5 + float(i)) * 3.0
		var r: float = orbit_radius + wobble
		var offset: Vector2 = Vector2(cos(angle), sin(angle)) * r
		branch_nodes[i].position = offset
		branch_nodes[i].rotation = angle + (PI * 0.5) + (sin(current_angle * 4.0) * 0.15)
		
	queue_redraw()
		
	# Dano contra o enxame em lote via SpatialHashGrid (T3, Seção 12.2)
	swarm_tick_timer += delta
	if swarm_tick_timer >= 0.2:
		swarm_tick_timer = 0.0
		var swarm_nodes: Array[Node] = get_tree().get_nodes_in_group("swarm_manager")
		if swarm_nodes.size() > 0:
			var swarm: EnemySwarmManager = swarm_nodes[0] as EnemySwarmManager
			for b in branch_nodes:
				swarm.damage_in_radius(b.global_position, 14.0, base_damage, 10.0)

func _draw() -> void:
	# Anel sutil de energia sagrada protetora ao redor do Vigilante
	draw_arc(Vector2.ZERO, orbit_radius, 0.0, TAU, 32, Color(0.4, 0.9, 0.35, 0.12), 1.5)
	
	# Rastros luminosos de folhas e bênçãos sagradas
	var step_angle: float = TAU / float(maxi(branches_count, 1))
	for i in range(branch_nodes.size()):
		var angle: float = current_angle + (i * step_angle)
		for t in range(1, 4):
			var trail_angle: float = angle - (float(t) * 0.12)
			var trail_pos: Vector2 = Vector2(cos(trail_angle), sin(trail_angle)) * orbit_radius
			var trail_alpha: float = 0.35 / float(t)
			draw_circle(trail_pos, 3.0 - float(t) * 0.6, Color(0.7, 1.0, 0.3, trail_alpha))

	# Limpa cooldowns antigos
	var current_time: float = Time.get_ticks_msec() / 1000.0
	var keys_to_remove: Array = []
	for id in enemy_damage_cooldowns:
		if current_time - enemy_damage_cooldowns[id] >= damage_interval:
			keys_to_remove.append(id)
	for id in keys_to_remove:
		enemy_damage_cooldowns.erase(id)

func rebuild_branches() -> void:
	# Remove galhos anteriores
	for b in branch_nodes:
		if is_instance_valid(b):
			b.queue_free()
	branch_nodes.clear()
	
	# Cria novos ramos orbitais
	for i in range(branches_count):
		var branch: Area2D = _create_branch_area(i)
		add_child(branch)
		branch_nodes.append(branch)

func _create_branch_area(index: int) -> Area2D:
	var area: Area2D = Area2D.new()
	area.name = "BranchArea_%d" % index
	area.collision_layer = 16
	area.collision_mask = 4 # Detecta inimigos (layer 4)
	
	# Forma de colisão circular
	var col: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 9.0
	col.shape = shape
	area.add_child(col)
	
	# Visual do galho com folhas de arruda
	var visual: Node2D = Node2D.new()
	
	# Caule
	var stem: Polygon2D = Polygon2D.new()
	stem.color = Color(0.28, 0.45, 0.22, 1.0)
	stem.polygon = PackedVector2Array([
		Vector2(-2, -8), Vector2(2, -8),
		Vector2(2, 8), Vector2(-2, 8)
	])
	visual.add_child(stem)
	
	# Folhas de arruda verdes vibrantes
	var leaves: Polygon2D = Polygon2D.new()
	leaves.color = Color(0.38, 0.72, 0.28, 1.0)
	leaves.polygon = PackedVector2Array([
		Vector2(0, -10), Vector2(6, -6), Vector2(2, -2),
		Vector2(7, 2), Vector2(0, 8), Vector2(-7, 2),
		Vector2(-2, -2), Vector2(-6, -6)
	])
	visual.add_child(leaves)
	
	# Brilho de energia sagrada
	var glow: Polygon2D = Polygon2D.new()
	glow.color = Color(0.85, 1.0, 0.4, 0.45)
	glow.polygon = PackedVector2Array([
		Vector2(0, -12), Vector2(8, 0), Vector2(0, 10), Vector2(-8, 0)
	])
	visual.add_child(glow)
	
	area.add_child(visual)
	area.body_entered.connect(func(body: Node2D) -> void: _on_branch_body_entered(body, area))
	
	return area

func _on_branch_body_entered(body: Node2D, branch_area: Area2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		var id: int = body.get_instance_id()
		var current_time: float = Time.get_ticks_msec() / 1000.0
		
		if not enemy_damage_cooldowns.has(id):
			enemy_damage_cooldowns[id] = current_time
			var knockback_dir: Vector2 = (body.global_position - branch_area.global_position).normalized()
			body.take_damage(base_damage, knockback_dir * 8.0)

## Aplica upgrades de poder
func add_branch() -> void:
	branches_count += 1
	rebuild_branches()

func increase_damage(percent: float) -> void:
	base_damage *= (1.0 + percent)

func increase_speed(percent: float) -> void:
	orbit_speed *= (1.0 + percent)
