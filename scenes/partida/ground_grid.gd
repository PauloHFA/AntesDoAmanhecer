@tool
extends Node2D

## Desenha uma grade de chão no estilo noturno sertanejo para dar sensação clara de velocidade e deslocamento.

@export var cell_size: int = 32
@export var grid_width: int = 40
@export var grid_height: int = 40
@export var bg_color: Color = Color(0.06, 0.08, 0.12, 1.0)
@export var line_color: Color = Color(0.12, 0.15, 0.22, 1.0)
@export var border_color: Color = Color(0.25, 0.30, 0.45, 1.0)

func _draw() -> void:
	var total_w: float = float(cell_size * grid_width)
	var total_h: float = float(cell_size * grid_height)
	var half_w: float = total_w * 0.5
	var half_h: float = total_h * 0.5
	
	# Fundo do chão
	draw_rect(Rect2(-half_w, -half_h, total_w, total_h), bg_color, true)
	
	# Linhas verticais
	for x in range(grid_width + 1):
		var pos_x: float = -half_w + (x * cell_size)
		draw_line(Vector2(pos_x, -half_h), Vector2(pos_x, half_h), line_color, 1.0)
		
	# Linhas horizontais
	for y in range(grid_height + 1):
		var pos_y: float = -half_h + (y * cell_size)
		draw_line(Vector2(-half_w, pos_y), Vector2(half_w, pos_y), line_color, 1.0)
		
	# Borda da arena
	draw_rect(Rect2(-half_w, -half_h, total_w, total_h), border_color, false, 2.0)
