extends Label

var timer_visivel = 0.0
const DURACAO_VISIVEL = 2.0
var combo_atual = 0
var escala_base = Vector2(1.0, 1.0)
var escala_alvo = Vector2(1.0, 1.0)

func _ready() -> void:
	visible = false
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pivot_offset = size * 0.5

func mostrar_combo(combo: int) -> void:
	combo_atual = combo
	if combo < 2:
		visible = false
		return

	text = "%d HITS" % combo
	visible = true
	timer_visivel = DURACAO_VISIVEL

	var fator = min(1.0 + (combo - 2) * 0.08, 1.6)
	escala_alvo = Vector2(fator, fator)
	scale = escala_alvo * 1.3

func _process(delta: float) -> void:
	if not visible:
		return

	timer_visivel -= delta
	if timer_visivel <= 0.0:
		visible = false
		return

	scale = scale.lerp(escala_alvo, 0.15)

	if timer_visivel < 0.5:
		modulate.a = timer_visivel / 0.5
	else:
		modulate.a = 1.0
