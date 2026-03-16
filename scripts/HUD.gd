extends CanvasLayer

const CENA_NUMERO_DANO = preload("res://scenes/ui/NumeroDano.tscn")
const CENA_COMBO = preload("res://scenes/ui/ComboDisplay.tscn")

@onready var desenho: Control = $Root/Desenho
@onready var label_central: Label = $Root/TextoCentral
@onready var camada_dano: Control = $Root/CamadaDano

var lutador1
var lutador2
var vida_p1 = 100.0
var vida_max_p1 = 100.0
var vida_p2 = 100.0
var vida_max_p2 = 100.0
var alvo_vida_p1 = 100.0
var alvo_vida_p2 = 100.0
var dano_vida_p1 = 100.0
var dano_vida_p2 = 100.0
var modo_treino = false
var nome_p1 = "P1"
var nome_p2 = "P2"
var rounds_p1 = 0
var rounds_p2 = 0
var rounds_alvo = 2
var timer_texto = "90"
var round_texto = "ROUND 1"
var combo_p1_display = null
var combo_p2_display = null

const BARRA_Y = 24.0
const BARRA_ALTURA = 32.0
const BARRA_LARGURA = 380.0
const INCLINACAO = 12.0
const TIMER_LARGURA = 80.0
const TIMER_ALTURA = 52.0
const COR_VIDA = Color(0.95, 0.85, 0.15)
const COR_VIDA_BAIXA = Color(0.9, 0.2, 0.1)
const COR_DANO = Color(0.85, 0.15, 0.15, 0.7)
const COR_FUNDO_BARRA = Color(0.12, 0.08, 0.08)
const COR_BORDA = Color(0.85, 0.75, 0.35)
const COR_TIMER_FUNDO = Color(0.05, 0.03, 0.03)
const COR_TIMER_BORDA = Color(0.9, 0.8, 0.3)

func configurar(novo_lutador1, novo_lutador2, em_treino: bool) -> void:
	lutador1 = novo_lutador1
	lutador2 = novo_lutador2
	modo_treino = em_treino
	nome_p1 = DadosPersonagens.obter_nome(lutador1.id_personagem)
	nome_p2 = DadosPersonagens.obter_nome(lutador2.id_personagem)
	vida_max_p1 = lutador1.vida_max
	vida_max_p2 = lutador2.vida_max
	vida_p1 = float(lutador1.vida_atual)
	vida_p2 = float(lutador2.vida_atual)
	alvo_vida_p1 = vida_p1
	alvo_vida_p2 = vida_p2
	dano_vida_p1 = vida_p1
	dano_vida_p2 = vida_p2
	lutador1.vida_alterada.connect(_on_vida_p1_alterada)
	lutador2.vida_alterada.connect(_on_vida_p2_alterada)
	label_central.visible = false
	_criar_combo_displays()

func _process(_delta: float) -> void:
	vida_p1 = lerpf(vida_p1, alvo_vida_p1, 0.18)
	vida_p2 = lerpf(vida_p2, alvo_vida_p2, 0.18)
	dano_vida_p1 = lerpf(dano_vida_p1, alvo_vida_p1, 0.04)
	dano_vida_p2 = lerpf(dano_vida_p2, alvo_vida_p2, 0.04)
	desenho.queue_redraw()

func atualizar_timer(tempo_restante: float) -> void:
	if modo_treino:
		timer_texto = "INF"
	else:
		timer_texto = str(max(0, int(ceil(tempo_restante))))

func atualizar_rounds(p1: int, p2: int, alvo: int) -> void:
	rounds_p1 = p1
	rounds_p2 = p2
	rounds_alvo = alvo
	if modo_treino:
		round_texto = "TREINO"
	else:
		round_texto = "ROUND %d" % [min(p1 + p2 + 1, alvo * 2 - 1)]

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
	var display = combo_p1_display if chave == "p1" else combo_p2_display
	if display != null and display.has_method("mostrar_combo"):
		display.mostrar_combo(combo)

func _on_vida_p1_alterada(vida_atual: int, _vida_max: int) -> void:
	alvo_vida_p1 = float(vida_atual)

func _on_vida_p2_alterada(vida_atual: int, _vida_max: int) -> void:
	alvo_vida_p2 = float(vida_atual)

func _criar_combo_displays() -> void:
	combo_p1_display = CENA_COMBO.instantiate()
	combo_p1_display.position = Vector2(180, 100)
	camada_dano.add_child(combo_p1_display)
	combo_p2_display = CENA_COMBO.instantiate()
	combo_p2_display.position = Vector2(780, 100)
	camada_dano.add_child(combo_p2_display)
