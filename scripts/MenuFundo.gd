extends Control

var tempo = 0.0

func _process(delta: float) -> void:
	tempo += delta

func _draw() -> void:
	var w = size.x
	var h = size.y

	# Dark gradient background
	draw_rect(Rect2(0, 0, w, h), Color(0.04, 0.02, 0.02))

	# Dramatic diagonal stripes
	var cor_faixa = Color(0.15, 0.04, 0.04, 0.3)
	for i in range(-5, 20):
		var x_base = i * 80.0 + sin(tempo * 0.3) * 10.0
		var pontos = PackedVector2Array([
			Vector2(x_base, 0),
			Vector2(x_base + 30, 0),
			Vector2(x_base + 30 - h * 0.3, h),
			Vector2(x_base - h * 0.3, h)
		])
		draw_colored_polygon(pontos, cor_faixa)

	# Red glow at bottom
	for i in range(8):
		var alfa = 0.04 * (8 - i)
		var y_pos = h - i * 30.0
		draw_rect(Rect2(0, y_pos, w, 30.0), Color(0.6, 0.08, 0.04, alfa))

	# Gold accent lines
	draw_line(Vector2(0, h * 0.3), Vector2(w, h * 0.3), Color(0.85, 0.7, 0.2, 0.08), 1.0)
	draw_line(Vector2(0, h * 0.7), Vector2(w, h * 0.7), Color(0.85, 0.7, 0.2, 0.08), 1.0)

	# Corner accents
	var canto = 40.0
	var cor_canto = Color(0.85, 0.7, 0.2, 0.25)
	# Top-left
	draw_line(Vector2(20, 20), Vector2(20 + canto, 20), cor_canto, 2.0)
	draw_line(Vector2(20, 20), Vector2(20, 20 + canto), cor_canto, 2.0)
	# Top-right
	draw_line(Vector2(w - 20, 20), Vector2(w - 20 - canto, 20), cor_canto, 2.0)
	draw_line(Vector2(w - 20, 20), Vector2(w - 20, 20 + canto), cor_canto, 2.0)
	# Bottom-left
	draw_line(Vector2(20, h - 20), Vector2(20 + canto, h - 20), cor_canto, 2.0)
	draw_line(Vector2(20, h - 20), Vector2(20, h - 20 - canto), cor_canto, 2.0)
	# Bottom-right
	draw_line(Vector2(w - 20, h - 20), Vector2(w - 20 - canto, h - 20), cor_canto, 2.0)
	draw_line(Vector2(w - 20, h - 20), Vector2(w - 20, h - 20 - canto), cor_canto, 2.0)
