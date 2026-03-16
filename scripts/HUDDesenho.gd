extends Control

var hud = null

func _ready() -> void:
	hud = get_parent().get_parent()

func _draw() -> void:
	if hud == null:
		return

	var centro_x = 512.0
	var topo_y = 16.0
	var barra_y = topo_y + 8.0
	var barra_h = 30.0
	var barra_w = 370.0
	var inclinacao = 10.0
	var timer_w = 72.0
	var timer_h = 48.0
	var espacamento = 8.0

	# Timer box
	var timer_x = centro_x - timer_w * 0.5
	var timer_y = topo_y
	_desenhar_caixa_timer(timer_x, timer_y, timer_w, timer_h)

	# Health bars
	var p1_x_fim = centro_x - timer_w * 0.5 - espacamento
	var p1_x_inicio = p1_x_fim - barra_w
	var p2_x_inicio = centro_x + timer_w * 0.5 + espacamento
	var p2_x_fim = p2_x_inicio + barra_w

	# P1 bar (fills from right to left, empties from left)
	var pct_p1 = clampf(hud.vida_p1 / hud.vida_max_p1, 0.0, 1.0)
	var pct_dano_p1 = clampf(hud.dano_vida_p1 / hud.vida_max_p1, 0.0, 1.0)
	_desenhar_barra_p1(p1_x_inicio, barra_y, barra_w, barra_h, inclinacao, pct_p1, pct_dano_p1)

	# P2 bar (fills from left to right, empties from right)
	var pct_p2 = clampf(hud.vida_p2 / hud.vida_max_p2, 0.0, 1.0)
	var pct_dano_p2 = clampf(hud.dano_vida_p2 / hud.vida_max_p2, 0.0, 1.0)
	_desenhar_barra_p2(p2_x_inicio, barra_y, barra_w, barra_h, inclinacao, pct_p2, pct_dano_p2)

	# Names
	var fonte = ThemeDB.fallback_font
	var tamanho_fonte = 14
	draw_string(fonte, Vector2(p1_x_inicio + inclinacao + 4, barra_y - 2), hud.nome_p1, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho_fonte, Color(1, 1, 1, 0.95))
	draw_string(fonte, Vector2(p2_x_fim - inclinacao - 4, barra_y - 2), hud.nome_p2, HORIZONTAL_ALIGNMENT_RIGHT, int(barra_w), tamanho_fonte, Color(1, 1, 1, 0.95))

	# Round dots
	var dot_y = barra_y + barra_h + 12
	_desenhar_round_dots(p1_x_fim - 8, dot_y, hud.rounds_p1, hud.rounds_alvo, true)
	_desenhar_round_dots(p2_x_inicio + 8, dot_y, hud.rounds_p2, hud.rounds_alvo, false)

	# Round text
	var round_y = dot_y + 4
	draw_string(fonte, Vector2(centro_x, round_y), hud.round_texto, HORIZONTAL_ALIGNMENT_CENTER, 200, 11, Color(0.8, 0.75, 0.5, 0.8))

func _desenhar_caixa_timer(x: float, y: float, w: float, h: float) -> void:
	var pontos = PackedVector2Array([
		Vector2(x + 4, y),
		Vector2(x + w - 4, y),
		Vector2(x + w, y + 4),
		Vector2(x + w, y + h - 4),
		Vector2(x + w - 4, y + h),
		Vector2(x + 4, y + h),
		Vector2(x, y + h - 4),
		Vector2(x, y + 4)
	])
	draw_colored_polygon(pontos, Color(0.05, 0.02, 0.02))
	draw_polyline(pontos + PackedVector2Array([pontos[0]]), Color(0.85, 0.7, 0.2), 2.0)

	var fonte = ThemeDB.fallback_font
	draw_string(fonte, Vector2(x + w * 0.5, y + h * 0.5 + 8), hud.timer_texto, HORIZONTAL_ALIGNMENT_CENTER, int(w), 22, Color(1, 1, 1))

func _desenhar_barra_p1(x: float, y: float, w: float, h: float, inc: float, pct: float, pct_dano: float) -> void:
	# Background (parallelogram slanting right)
	var fundo = PackedVector2Array([
		Vector2(x + inc, y),
		Vector2(x + w, y),
		Vector2(x + w - inc, y + h),
		Vector2(x, y + h)
	])
	draw_colored_polygon(fundo, Color(0.1, 0.06, 0.06))

	# Damage trail (red, slower lerp)
	if pct_dano > pct:
		var dano_w = w * pct_dano
		var fill_x = x + w - dano_w
		var dano = PackedVector2Array([
			Vector2(fill_x + inc * (1.0 - pct_dano), y),
			Vector2(x + w, y),
			Vector2(x + w - inc, y + h),
			Vector2(fill_x - inc * pct_dano, y + h)
		])
		draw_colored_polygon(dano, Color(0.7, 0.12, 0.08, 0.6))

	# Health fill
	if pct > 0.01:
		var fill_w = w * pct
		var fill_x = x + w - fill_w
		var cor = hud.COR_VIDA
		if pct < 0.25:
			cor = hud.COR_VIDA_BAIXA
		elif pct < 0.5:
			cor = hud.COR_VIDA.lerp(hud.COR_VIDA_BAIXA, (0.5 - pct) / 0.25)

		var vida = PackedVector2Array([
			Vector2(fill_x + inc * (1.0 - pct), y + 1),
			Vector2(x + w - 1, y + 1),
			Vector2(x + w - inc - 1, y + h - 1),
			Vector2(fill_x - inc * pct, y + h - 1)
		])
		draw_colored_polygon(vida, cor)

		# Highlight
		var brilho = PackedVector2Array([
			Vector2(fill_x + inc * (1.0 - pct), y + 1),
			Vector2(x + w - 1, y + 1),
			Vector2(x + w - inc * 0.5 - 1, y + h * 0.35),
			Vector2(fill_x + inc * (1.0 - pct) * 0.5, y + h * 0.35)
		])
		draw_colored_polygon(brilho, Color(1, 1, 1, 0.12))

	# Border
	draw_polyline(fundo + PackedVector2Array([fundo[0]]), Color(0.8, 0.7, 0.25), 2.0)

func _desenhar_barra_p2(x: float, y: float, w: float, h: float, inc: float, pct: float, pct_dano: float) -> void:
	# Background (parallelogram slanting left)
	var fundo = PackedVector2Array([
		Vector2(x, y),
		Vector2(x + w - inc, y),
		Vector2(x + w, y + h),
		Vector2(x + inc, y + h)
	])
	draw_colored_polygon(fundo, Color(0.1, 0.06, 0.06))

	# Damage trail
	if pct_dano > pct:
		var dano_w = w * pct_dano
		var dano = PackedVector2Array([
			Vector2(x, y),
			Vector2(x + dano_w - inc * (1.0 - pct_dano), y),
			Vector2(x + dano_w + inc * pct_dano, y + h),
			Vector2(x + inc, y + h)
		])
		draw_colored_polygon(dano, Color(0.7, 0.12, 0.08, 0.6))

	# Health fill
	if pct > 0.01:
		var fill_w = w * pct
		var cor = hud.COR_VIDA
		if pct < 0.25:
			cor = hud.COR_VIDA_BAIXA
		elif pct < 0.5:
			cor = hud.COR_VIDA.lerp(hud.COR_VIDA_BAIXA, (0.5 - pct) / 0.25)

		var vida = PackedVector2Array([
			Vector2(x + 1, y + 1),
			Vector2(x + fill_w - inc * (1.0 - pct) + 1, y + 1),
			Vector2(x + fill_w + inc * pct + 1, y + h - 1),
			Vector2(x + inc + 1, y + h - 1)
		])
		draw_colored_polygon(vida, cor)

		# Highlight
		var brilho = PackedVector2Array([
			Vector2(x + 1, y + 1),
			Vector2(x + fill_w - inc * (1.0 - pct) + 1, y + 1),
			Vector2(x + fill_w - inc * (1.0 - pct) * 0.5 + 1, y + h * 0.35),
			Vector2(x + inc * 0.5 + 1, y + h * 0.35)
		])
		draw_colored_polygon(brilho, Color(1, 1, 1, 0.12))

	# Border
	draw_polyline(fundo + PackedVector2Array([fundo[0]]), Color(0.8, 0.7, 0.25), 2.0)

func _desenhar_round_dots(x: float, y: float, ganhos: int, alvo: int, alinhar_direita: bool) -> void:
	var raio = 5.0
	var espacamento = 14.0

	for i in alvo:
		var offset_x: float
		if alinhar_direita:
			offset_x = x - (alvo - 1 - i) * espacamento
		else:
			offset_x = x + i * espacamento

		if i < ganhos:
			draw_circle(Vector2(offset_x, y), raio, Color(0.95, 0.8, 0.15))
			draw_circle(Vector2(offset_x, y), raio + 1, Color(0.95, 0.8, 0.15, 0.3))
		else:
			draw_circle(Vector2(offset_x, y), raio, Color(0.3, 0.25, 0.15, 0.5))
			draw_arc(Vector2(offset_x, y), raio, 0, TAU, 16, Color(0.6, 0.5, 0.2, 0.4), 1.0)
