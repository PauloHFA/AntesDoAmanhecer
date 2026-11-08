class_name TreasureChest
extends Area2D

## Baú de Tesouro deixado por Elites e Chefes (RF-08, CA-07, Seção 5.7)
## Concede evolução de arma garantida se os requisitos da receita forem cumpridos.

@export var gold_reward: int = 50
var is_opened: bool = false

@onready var visual: Node2D = $Visual

func _ready() -> void:
	add_to_group("chests")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_opened or not body.is_in_group("player"):
		return
		
	is_opened = true
	_open_chest()

func _open_chest() -> void:
	# Pausa a partida para a roleta do baú
	get_tree().paused = true
	
	var chest_menus: Array[Node] = get_tree().get_nodes_in_group("chest_menu")
	if chest_menus.size() > 0:
		var menu: Node = chest_menus[0]
		if menu.has_method("open_roulette"):
			menu.open_roulette(gold_reward)
	else:
		# Fallback se a UI não estiver presente
		if has_node("/root/EventBus"):
			EventBus.gold_collected.emit(gold_reward, 0)
		get_tree().paused = false
		
	queue_free()
