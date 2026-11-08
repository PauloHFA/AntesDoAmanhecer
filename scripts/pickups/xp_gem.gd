class_name XPGem
extends Area2D

## Gema de Experiência deixada por inimigos derrotados (RF-04).
## É atraída pelo jogador e concede XP ao ser recolhida.

@export var xp_value: int = 5
@export var magnet_radius: float = 75.0
@export var max_fly_speed: float = 380.0
@export var acceleration: float = 650.0

var is_being_attracted: bool = false
var current_speed: float = 0.0
var target_player: Node2D = null

@onready var visual: Polygon2D = $Visual
@onready var anim_timer: float = randf() * 10.0

func _ready() -> void:
	add_to_group("pickups")
	body_entered.connect(_on_body_entered)

func set_xp_value(value: int) -> void:
	xp_value = value
	# Muda cor de acordo com a quantidade
	if xp_value >= 25:
		if visual: visual.color = Color(1.0, 0.35, 0.45, 1.0) # Rubi (Elites)
	elif xp_value >= 10:
		if visual: visual.color = Color(0.2, 0.9, 0.6, 1.0)  # Esmeralda
	else:
		if visual: visual.color = Color(0.3, 0.75, 1.0, 1.0) # Turquesa padrão

func _physics_process(delta: float) -> void:
	anim_timer += delta * 4.0
	# Leve flutuação vertical decorativa
	if visual and not is_being_attracted:
		visual.position.y = sin(anim_timer) * 2.0
		
	if not is_being_attracted:
		_check_for_player_magnet()
	else:
		if is_instance_valid(target_player):
			var to_player: Vector2 = target_player.global_position - global_position
			var distance: float = to_player.length()
			
			if distance <= 12.0:
				_collect()
				return
				
			current_speed = move_toward(current_speed, max_fly_speed, acceleration * delta)
			global_position += to_player.normalized() * current_speed * delta
		else:
			is_being_attracted = false

func _check_for_player_magnet() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p: Node2D = players[0] as Node2D
		if global_position.distance_to(p.global_position) <= magnet_radius:
			target_player = p
			is_being_attracted = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_collect()

func _collect() -> void:
	if has_node("/root/EventBus"):
		# Emite com XP coletado
		EventBus.xp_collected.emit(xp_value, 0, 0)
	queue_free()
