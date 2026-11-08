class_name DamageNumberPool
extends Node2D

## Pool de Números de Dano Flutuantes de Alto Desempenho (Seção 10.2, 12.2)
## Pré-aloca instâncias de texto e as recicla para evitar instanciar/destruir nós em tempo real.

@export var pool_size: int = 60

class ActiveNumber:
	var label: Label
	var world_pos: Vector2
	var velocity: Vector2
	var lifetime: float
	var max_lifetime: float

var free_labels: Array[Label] = []
var active_numbers: Array[ActiveNumber] = []

func _ready() -> void:
	add_to_group("damage_pool")
	_initialize_pool()

func _initialize_pool() -> void:
	for i in range(pool_size):
		var lbl: Label = Label.new()
		lbl.visible = false
		lbl.theme_override_font_sizes/font_size = 10
		lbl.theme_override_colors/font_outline_color = Color.BLACK
		lbl.theme_override_constants/outline_size = 2
		add_child(lbl)
		free_labels.append(lbl)

func spawn_number(pos: Vector2, amount: float, is_crit: bool = false) -> void:
	# Verifica se as configurações permitem
	var s_nodes: Array[Node] = get_tree().get_nodes_in_group("settings")
	if s_nodes.size() > 0:
		var s: SettingsManager = s_nodes[0] as SettingsManager
		if not s.damage_numbers_enabled:
			return
			
	if free_labels.is_empty():
		return # Evita alocação extra
		
	var lbl: Label = free_labels.pop_back()
	lbl.text = str(int(round(amount)))
	lbl.visible = true
	
	if is_crit:
		lbl.modulate = Color(1.0, 0.3, 0.3, 1.0) # Vermelho de crítico
		lbl.theme_override_font_sizes/font_size = 12
	else:
		lbl.modulate = Color(1.0, 0.9, 0.4, 1.0) # Amarelo ouro
		lbl.theme_override_font_sizes/font_size = 10
		
	var active: ActiveNumber = ActiveNumber.new()
	active.label = lbl
	active.world_pos = pos + Vector2(randf_range(-6.0, 6.0), -10.0)
	active.velocity = Vector2(randf_range(-18.0, 18.0), randf_range(-45.0, -60.0))
	active.lifetime = 0.45
	active.max_lifetime = 0.45
	active_numbers.append(active)

func _process(delta: float) -> void:
	var i: int = active_numbers.size() - 1
	while i >= 0:
		var n: ActiveNumber = active_numbers[i]
		n.lifetime -= delta
		n.velocity.y += 120.0 * delta # Gravidade
		n.world_pos += n.velocity * delta
		
		# Atualiza posição e fade-out
		n.label.global_position = n.world_pos
		var alpha: float = clampf(n.lifetime / n.max_lifetime, 0.0, 1.0)
		n.label.modulate.a = alpha
		
		if n.lifetime <= 0.0:
			n.label.visible = false
			free_labels.append(n.label)
			active_numbers.remove_at(i)
		i -= 1
