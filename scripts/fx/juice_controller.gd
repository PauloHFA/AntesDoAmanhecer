class_name JuiceController
extends Node2D

## Controlador de Juice e Impacto Visual (Seção 10.2, Seção 10.3)
## Gerencia Hit-stop, Tremor de Tela (Trauma-based), Vinheta de Dano e Zoom de Level Up.

@export var max_offset_px: float = 12.0
@export var max_roll_rad: float = 0.05
@export var trauma_decay: float = 2.2 # Taxa de decaimento por segundo

var trauma: float = 0.0
var camera_ref: Camera2D = null
var vignette_rect: ColorRect = null
var vignette_alpha: float = 0.0

@onready var settings: SettingsManager = null

func _ready() -> void:
	add_to_group("juice")
	_find_camera()
	_setup_vignette()
	
	if has_node("/root/EventBus"):
		EventBus.player_damaged.connect(_on_player_damaged)
		EventBus.level_up_triggered.connect(_on_level_up)
		
	var s_nodes: Array[Node] = get_tree().get_nodes_in_group("settings")
	if s_nodes.size() > 0:
		settings = s_nodes[0] as SettingsManager

func _process(delta: float) -> void:
	# Atualiza decaimento de trauma e tremor de tela
	if trauma > 0.0:
		trauma = move_toward(trauma, 0.0, delta * trauma_decay)
		_apply_shake()
	elif camera_ref and camera_ref.offset != Vector2.ZERO:
		camera_ref.offset = Vector2.ZERO
		camera_ref.rotation = 0.0
		
	# Atualiza vinheta vermelha de dano
	if vignette_alpha > 0.0:
		vignette_alpha = move_toward(vignette_alpha, 0.0, delta * 3.5)
		if vignette_rect:
			vignette_rect.color = Color(0.8, 0.1, 0.1, vignette_alpha)

## Adiciona trauma para tremor de tela (0.0 a 1.0)
func add_trauma(amount: float) -> void:
	var intensity: float = settings.screen_shake_intensity if settings else 1.0
	if intensity <= 0.0:
		return
	trauma = clampf(trauma + (amount * intensity), 0.0, 1.0)

func _apply_shake() -> void:
	if not is_instance_valid(camera_ref):
		_find_camera()
		if not is_instance_valid(camera_ref):
			return
			
	var shake: float = trauma * trauma # Não-linear para impacto realista
	var intensity: float = settings.screen_shake_intensity if settings else 1.0
	var offset_x: float = max_offset_px * shake * randf_range(-1.0, 1.0) * intensity
	var offset_y: float = max_offset_px * shake * randf_range(-1.0, 1.0) * intensity
	var roll: float = max_roll_rad * shake * randf_range(-1.0, 1.0) * intensity
	
	camera_ref.offset = Vector2(offset_x, offset_y)
	camera_ref.rotation = roll

## Congelamento breve de impacto (Hit-stop - Seção 10.2)
func hit_stop(duration_ms: float = 60.0) -> void:
	if settings and not settings.hit_stop_enabled:
		return
	var duration_sec: float = duration_ms / 1000.0
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration_sec, true, false, true).timeout
	Engine.time_scale = 1.0

func _on_player_damaged(_cur: int, _max_hp: int) -> void:
	add_trauma(0.5)
	vignette_alpha = 0.35 # Flash vermelho nas bordas
	hit_stop(70.0)

func _on_level_up(_new_lvl: int) -> void:
	add_trauma(0.2)

func _setup_vignette() -> void:
	var canvas_layer: CanvasLayer = CanvasLayer.new()
	canvas_layer.layer = 100 # Topo absoluto
	add_child(canvas_layer)
	
	vignette_rect = ColorRect.new()
	vignette_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette_rect.color = Color(0.8, 0.1, 0.1, 0.0)
	canvas_layer.add_child(vignette_rect)

func _find_camera() -> void:
	var viewport: Viewport = get_viewport()
	if viewport:
		camera_ref = viewport.get_camera_2d()
