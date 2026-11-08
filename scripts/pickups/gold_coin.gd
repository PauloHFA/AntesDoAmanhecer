class_name GoldCoin
extends Area2D

## Moeda de Ouro coletável para o Candeeiro (RF-04, Seção 5.7)
## Atraída pelo jogador e acumulada para melhorias permanentes.

@export var gold_value: int = 1
@export var magnet_radius: float = 85.0
@export var max_fly_speed: float = 420.0
@export var acceleration: float = 700.0

var is_being_attracted: bool = false
var current_speed: float = 0.0
var target_player: Node2D = null

@onready var visual: Polygon2D = $Visual
var anim_timer: float = 0.0

func _ready() -> void:
	add_to_group("pickups")
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	anim_timer += delta * 5.0
	# Efeito visual de giro brilhante da moeda
	if visual and not is_being_attracted:
		visual.scale.x = absf(cos(anim_timer))
		
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
		EventBus.gold_collected.emit(gold_value, 0)
	queue_free()
