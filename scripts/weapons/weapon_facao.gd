class_name WeaponFacao
extends Node2D

## Arma: Facão (Arco Frontal - Seção 7.1)
## Desfere golpes cortantes em arco frontal repelindo inimigos.
## Evolui para "Facão Furioso" (arco duplo de 360 graus com giro devastador).

@export var base_damage: float = 26.0
@export var cooldown: float = 0.95
@export var slash_radius: float = 55.0
@export var is_evolved: bool = false # Facão Furioso

var slash_timer: float = 0.0
var visual_slash_progress: float = -1.0
var player_ref: Player = null

func _ready() -> void:
	add_to_group("weapons")
	_find_player()

func _physics_process(delta: float) -> void:
	slash_timer += delta
	if slash_timer >= cooldown:
		slash_timer = 0.0
		_execute_slash()
		
	if visual_slash_progress >= 0.0:
		visual_slash_progress += delta * 6.0
		if visual_slash_progress > 1.0:
			visual_slash_progress = -1.0
		queue_redraw()

func _execute_slash() -> void:
	if not is_instance_valid(player_ref):
		_find_player()
		if not is_instance_valid(player_ref):
			return
			
	var facing: Vector2 = player_ref.facing_direction
	if facing == Vector2.ZERO:
		facing = Vector2.RIGHT
		
	var slash_center: Vector2 = global_position + (facing * 24.0)
	var r: float = slash_radius * (1.4 if is_evolved else 1.0)
	var dmg: float = base_damage * (1.8 if is_evolved else 1.0)
	
	visual_slash_progress = 0.0
	
	# Micro-avanço corporal (Lunge de estocada) para dar peso ao golpe
	if is_instance_valid(player_ref) and player_ref.visual_root:
		player_ref.visual_root.position += facing * 4.5
	
	var swarm_nodes: Array[Node] = get_tree().get_nodes_in_group("swarm_manager")
	if swarm_nodes.size() > 0:
		var swarm: EnemySwarmManager = swarm_nodes[0] as EnemySwarmManager
		var hits: int = swarm.damage_in_radius(slash_center, r, dmg, 25.0)
		if hits > 0:
			var juice_nodes: Array[Node] = get_tree().get_nodes_in_group("juice")
			if juice_nodes.size() > 0:
				var j: JuiceController = juice_nodes[0] as JuiceController
				j.add_trauma(0.15)
				j.hit_stop(30.0)

func _draw() -> void:
	if visual_slash_progress < 0.0:
		return
		
	var facing: Vector2 = player_ref.facing_direction if is_instance_valid(player_ref) else Vector2.RIGHT
	var base_angle: float = facing.angle()
	var arc_spread: float = TAU if is_evolved else (PI * 0.85)
	var alpha: float = 1.0 - visual_slash_progress
	
	# Paleta visual de corte
	var outer_col: Color = Color(1.0, 0.95, 0.5, alpha) if not is_evolved else Color(1.0, 0.25, 0.45, alpha)
	var inner_col: Color = Color(1.0, 0.7, 0.15, alpha * 0.5) if not is_evolved else Color(0.8, 0.1, 0.2, alpha * 0.5)
	var core_white: Color = Color(2.5, 2.5, 2.2, alpha)
	
	var r_outer: float = slash_radius * (1.35 if is_evolved else 1.0)
	var r_inner: float = r_outer * 0.55
	var segments: int = 24 if is_evolved else 16
	
	var start_ang: float = base_angle - (arc_spread * 0.5)
	var end_ang: float = base_angle + (arc_spread * 0.5)
	var step: float = arc_spread / float(segments)
	
	# Desenha leque volumoso de corte (Swoosh em Mesh)
	var outer_pts: PackedVector2Array = PackedVector2Array()
	var inner_pts: PackedVector2Array = PackedVector2Array()
	
	for s in range(segments + 1):
		var ang: float = start_ang + (s * step)
		var dir_vec: Vector2 = Vector2(cos(ang), sin(ang))
		outer_pts.append(dir_vec * r_outer)
		inner_pts.append(dir_vec * r_inner)
		
	# Constrói triângulos do rastro
	for s in range(segments):
		var tri1: PackedVector2Array = PackedVector2Array([outer_pts[s], outer_pts[s+1], inner_pts[s+1]])
		var tri2: PackedVector2Array = PackedVector2Array([outer_pts[s], inner_pts[s+1], inner_pts[s]])
		var col: Color = outer_col if s > segments / 2 else inner_col
		draw_colored_polygon(tri1, col)
		draw_colored_polygon(tri2, col)
		
	# Borda frontal branca incandescente (Fio da lâmina)
	draw_polyline(outer_pts, core_white, 2.5)
	
	# Faíscas pontuais voando da lâmina
	if alpha > 0.3:
		var spark_ang: float = end_ang - (arc_spread * 0.2 * randf())
		var spark_pos: Vector2 = Vector2(cos(spark_ang), sin(spark_ang)) * (r_outer + randf_range(2.0, 8.0))
		draw_circle(spark_pos, 2.0, Color(2.5, 2.2, 1.2, alpha))

func evolve_weapon() -> void:
	is_evolved = true
	base_damage = 50.0
	cooldown = 0.65
	slash_radius = 75.0

func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as Player
