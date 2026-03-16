extends Label

var velocidade = Vector2(0, -50)
var tempo_vida = 0.9
var tempo_max = 0.9
var escala_alvo = Vector2(1.0, 1.0)

func configurar(dano: int, combo: int) -> void:
	text = str(dano)
	if combo >= 5:
		modulate = Color(1.0, 0.3, 0.1)
		escala_alvo = Vector2(1.5, 1.5)
		velocidade = Vector2(randf_range(-15.0, 15.0), -70)
		tempo_vida = 1.1
		tempo_max = 1.1
	elif combo >= 3:
		modulate = Color(1.0, 0.65, 0.1)
		escala_alvo = Vector2(1.25, 1.25)
		velocidade = Vector2(randf_range(-10.0, 10.0), -60)
		tempo_vida = 1.0
		tempo_max = 1.0
	elif combo >= 2:
		modulate = Color(1.0, 0.84, 0.2)
		escala_alvo = Vector2(1.1, 1.1)
		velocidade = Vector2(randf_range(-8.0, 8.0), -55)
	else:
		modulate = Color(1.0, 0.35, 0.35)
		velocidade = Vector2(randf_range(-5.0, 5.0), -50)

	scale = escala_alvo * 1.4
	pivot_offset = size * 0.5

func _process(delta: float) -> void:
	position += velocidade * delta
	velocidade.y += 30.0 * delta
	tempo_vida -= delta

	scale = scale.lerp(escala_alvo, 0.12)

	var progresso = 1.0 - (tempo_vida / tempo_max)
	if progresso > 0.7:
		modulate.a = clampf((1.0 - progresso) / 0.3, 0.0, 1.0)

	if tempo_vida <= 0.0:
		queue_free()
