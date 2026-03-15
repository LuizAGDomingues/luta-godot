extends Label

var velocidade = Vector2(0, -42)
var tempo_vida = 0.8

func configurar(dano: int, combo: int) -> void:
	text = str(dano)
	if combo >= 2:
		modulate = Color(1.0, 0.84, 0.2)
	else:
		modulate = Color(1.0, 0.35, 0.35)

func _process(delta: float) -> void:
	position += velocidade * delta
	tempo_vida -= delta
	modulate.a = clampf(tempo_vida / 0.8, 0.0, 1.0)
	if tempo_vida <= 0.0:
		queue_free()
