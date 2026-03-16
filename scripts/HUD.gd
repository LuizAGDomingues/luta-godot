extends CanvasLayer

const CENA_NUMERO_DANO = preload("res://scenes/ui/NumeroDano.tscn")
const CENA_COMBO = preload("res://scenes/ui/ComboDisplay.tscn")

@onready var nome_p1: Label = $Root/Topo/LadoP1/NomeP1
@onready var nome_p2: Label = $Root/Topo/LadoP2/NomeP2
@onready var rounds_p1: Label = $Root/Topo/LadoP1/RoundP1
@onready var rounds_p2: Label = $Root/Topo/LadoP2/RoundP2
@onready var barra_p1: ProgressBar = $Root/Topo/LadoP1/BarraVidaP1
@onready var barra_p2: ProgressBar = $Root/Topo/LadoP2/BarraVidaP2
@onready var label_timer: Label = $Root/Topo/Centro/TimerBg/Timer
@onready var label_rounds: Label = $Root/Topo/Centro/Rounds
@onready var label_central: Label = $Root/TextoCentral
@onready var camada_dano: Control = $Root/CamadaDano

var lutador1
var lutador2
var alvo_vida_p1 = 100.0
var alvo_vida_p2 = 100.0
var modo_treino = false
var combo_p1: Label = null
var combo_p2: Label = null

func configurar(novo_lutador1, novo_lutador2, em_treino: bool) -> void:
	lutador1 = novo_lutador1
	lutador2 = novo_lutador2
	modo_treino = em_treino
	nome_p1.text = DadosPersonagens.obter_nome(lutador1.id_personagem)
	nome_p2.text = DadosPersonagens.obter_nome(lutador2.id_personagem)
	barra_p1.max_value = lutador1.vida_max
	barra_p2.max_value = lutador2.vida_max
	barra_p1.value = lutador1.vida_atual
	barra_p2.value = lutador2.vida_atual
	barra_p1.modulate = Color(0.51, 0.55, 0.97, 1.0)
	barra_p2.modulate = Color(0.51, 0.55, 0.97, 1.0)
	alvo_vida_p1 = lutador1.vida_atual
	alvo_vida_p2 = lutador2.vida_atual
	lutador1.vida_alterada.connect(_on_vida_p1_alterada)
	lutador2.vida_alterada.connect(_on_vida_p2_alterada)
	label_central.visible = false
	_criar_combo_displays()

func _process(_delta: float) -> void:
	barra_p1.value = lerpf(float(barra_p1.value), alvo_vida_p1, 0.18)
	barra_p2.value = lerpf(float(barra_p2.value), alvo_vida_p2, 0.18)

func atualizar_timer(tempo_restante: float) -> void:
	if modo_treino:
		label_timer.text = "TREINO"
	else:
		label_timer.text = str(max(0, int(ceil(tempo_restante))))

func atualizar_rounds(rounds_p1: int, rounds_p2: int, alvo: int) -> void:
	if modo_treino:
		label_rounds.text = "TREINO"
		self.rounds_p1.text = ""
		self.rounds_p2.text = ""
	else:
		label_rounds.text = "ROUND %d" % [min(rounds_p1 + rounds_p2 + 1, alvo * 2 - 1)]
		self.rounds_p1.text = _gerar_dots(rounds_p1, alvo)
		self.rounds_p2.text = _gerar_dots(rounds_p2, alvo)

func mostrar_texto(texto: String) -> void:
	label_central.text = texto
	label_central.visible = true

func esconder_texto() -> void:
	label_central.visible = false

func exibir_numero_dano(posicao_mundo: Vector2, dano: int, combo: int) -> void:
	var numero = CENA_NUMERO_DANO.instantiate()
	numero.position = Vector2(posicao_mundo.x, posicao_mundo.y)
	camada_dano.add_child(numero)
	if numero.has_method("configurar"):
		numero.configurar(dano, combo)

func atualizar_combo(chave: String, combo: int) -> void:
	var display = combo_p1 if chave == "p1" else combo_p2
	if display != null and display.has_method("mostrar_combo"):
		display.mostrar_combo(combo)

func _on_vida_p1_alterada(vida_atual: int, _vida_max: int) -> void:
	alvo_vida_p1 = vida_atual

func _on_vida_p2_alterada(vida_atual: int, _vida_max: int) -> void:
	alvo_vida_p2 = vida_atual

func _criar_combo_displays() -> void:
	combo_p1 = CENA_COMBO.instantiate()
	combo_p1.position = Vector2(180, 130)
	camada_dano.add_child(combo_p1)
	combo_p2 = CENA_COMBO.instantiate()
	combo_p2.position = Vector2(780, 130)
	camada_dano.add_child(combo_p2)

func _gerar_dots(valor, alvo):
	var dots = []
	for indice in alvo:
		if indice < valor:
			dots.append("●")
		else:
			dots.append("○")
	return " ".join(dots)
