extends Node2D

const DURACAO_PARTICULA = 0.35
const DURACAO_POEIRA = 0.4

var particulas: Array = []

func criar_hit_sparks(posicao: Vector2, combo: int) -> void:
	var qtd = 6 + min(combo, 6) * 2
	var cor_base = Color(1.0, 0.9, 0.3)
	if combo >= 3:
		cor_base = Color(1.0, 0.5, 0.1)
	if combo >= 5:
		cor_base = Color(1.0, 0.2, 0.2)

	for i in qtd:
		var angulo = randf() * TAU
		var velocidade = randf_range(120.0, 280.0 + combo * 30.0)
		var particula = {
			"pos": posicao,
			"vel": Vector2(cos(angulo) * velocidade, sin(angulo) * velocidade),
			"cor": cor_base.lerp(Color.WHITE, randf() * 0.4),
			"tempo": DURACAO_PARTICULA,
			"tempo_max": DURACAO_PARTICULA,
			"tamanho": randf_range(2.0, 4.5),
			"tipo": "spark"
		}
		particulas.append(particula)

func criar_poeira_aterrissagem(posicao: Vector2) -> void:
	for i in 5:
		var direcao = -1.0 if i % 2 == 0 else 1.0
		var particula = {
			"pos": posicao,
			"vel": Vector2(direcao * randf_range(30.0, 80.0), randf_range(-20.0, -50.0)),
			"cor": Color(0.7, 0.65, 0.55, 0.6),
			"tempo": DURACAO_POEIRA,
			"tempo_max": DURACAO_POEIRA,
			"tamanho": randf_range(3.0, 6.0),
			"tipo": "dust"
		}
		particulas.append(particula)

func criar_poeira_dash(posicao: Vector2, direcao: int) -> void:
	for i in 4:
		var particula = {
			"pos": posicao + Vector2(randf_range(-8.0, 8.0), randf_range(-5.0, 0.0)),
			"vel": Vector2(float(-direcao) * randf_range(40.0, 100.0), randf_range(-30.0, -60.0)),
			"cor": Color(0.75, 0.7, 0.6, 0.5),
			"tempo": DURACAO_POEIRA,
			"tempo_max": DURACAO_POEIRA,
			"tamanho": randf_range(3.5, 7.0),
			"tipo": "dust"
		}
		particulas.append(particula)

func _process(delta: float) -> void:
	var i = particulas.size() - 1
	while i >= 0:
		var p = particulas[i]
		p["tempo"] -= delta
		if p["tempo"] <= 0.0:
			particulas.remove_at(i)
		else:
			p["pos"] += p["vel"] * delta
			if p["tipo"] == "spark":
				p["vel"].y += 400.0 * delta
			elif p["tipo"] == "dust":
				p["vel"] *= 0.92
		i -= 1
	queue_redraw()

func _draw() -> void:
	for p in particulas:
		var alfa = clampf(p["tempo"] / p["tempo_max"], 0.0, 1.0)
		var cor = p["cor"]
		cor.a *= alfa
		var tam = p["tamanho"] * alfa
		if p["tipo"] == "spark":
			draw_rect(Rect2(p["pos"] - Vector2(tam * 0.5, tam * 0.5), Vector2(tam, tam)), cor, true)
		else:
			draw_circle(p["pos"], tam, cor)
