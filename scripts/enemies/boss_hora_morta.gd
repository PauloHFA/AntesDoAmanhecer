class_name BossHoraMorta
extends CharacterBody2D

## Entidade do Fim dos Tempos: A Hora Morta (Seção 5.6, Seção 8.1)
## Surge após os 20:00 no modo Noite Infinita. Rápida e quase invencível.

@export var max_health: float = 99999.0
@export var speed: float = 145.0
@export var contact_damage: int = 45

var player_ref: Player = null

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses")
	_find_player()
	
	# Efeito aterrador de aparição
	var juice_nodes: Array[Node] = get_tree().get_nodes_in_group("juice")
	if juice_nodes.size() > 0:
		var j: JuiceController = juice_nodes[0] as JuiceController
		j.add_trauma(0.9)
		j.hit_stop(90.0)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player_ref):
		_find_player()
		return
		
	var dir: Vector2 = (player_ref.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var col: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = col.get_collider()
		if collider and collider.is_in_group("player") and collider.has_method("take_damage"):
			collider.take_damage(contact_damage)

func take_damage(_amount: float, _kb: Vector2 = Vector2.ZERO) -> void:
	# Quase invencível: apenas pisca de leve
	modulate = Color(2.0, 2.0, 2.0, 1.0)
	get_tree().create_timer(0.05, false, false, true).timeout.connect(func() -> void:
		modulate = Color.WHITE
	)

func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0] as Player
