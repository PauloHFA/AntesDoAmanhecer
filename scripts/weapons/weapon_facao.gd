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
		
	var slash_center: Vector2 = global_position + (facing * 22.0)
	var r: float = slash_radius * (1.4 if is_evolved else 1.0)
	var dmg: float = base_damage * (1.8 if is_evolved else 1.0)
	
	visual_slash_progress = 0.0
	
	var swarm_nodes: Array[Node] = get_tree().get_nodes_in_group("swarm_manager")
	if swarm_nodes.size() > 0:
		var swarm: EnemySwarmManager = swarm_nodes[0] as EnemySwarmManager
		swarm.damage_in_radius(slash_center, r, dmg, 22.0)

func _draw() -> void:
	if visual_slash_progress < 0.0:
		return
		
	var facing: Vector2 = player_ref.facing_direction if is_instance_valid(player_ref) else Vector2.RIGHT
	var base_angle: float = facing.angle()
	var arc_spread: float = TAU if is_evolved else (PI * 0.75)
	var slash_col: Color = Color(1.0, 0.85, 0.3, 1.0 - visual_slash_progress) if not is_evolved else Color(1.0, 0.2, 0.4, 1.0 - visual_slash_progress)
	
	draw_arc(Vector2.ZERO, slash_radius, base_angle - (arc_spread * 0.5), base_angle + (arc_spread * 0.5), 16, slash_col, 4.0)

func evolve_weapon() -> void:
	is_evolved = true
	base_damage = 50.0
	cooldown = 0.65
	slash_radius = 75.0

func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as Player
