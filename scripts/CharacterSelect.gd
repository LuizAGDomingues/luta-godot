extends Control

const COLUNAS = 4
const LINHAS = 2
const TAMANHO_CELULA = Vector2(90, 90)
const ESPACO = 6.0

const COR_CURSOR_P1 = Color(0.3, 0.5, 1.0, 0.9)
const COR_CURSOR_P2 = Color(1.0, 0.3, 0.4, 0.9)
const COR_CELULA = Color(0.08, 0.05, 0.05, 0.9)
const COR_BORDA_CELULA = Color(0.5, 0.4, 0.15, 0.3)
const COR_CONFIRMADO = Color(0.2, 0.9, 0.3, 0.8)

@onready var fundo: Control = $Fundo
@onready var grade: Control = $Layout/Coluna/Centro/GradeContainer/Grade
@onready var titulo_modo: Label = $Layout/Coluna/TituloModo
@onready var preview_p1: TextureRect = $Layout/Coluna/Centro/PainelP1/MargemP1/ColunaP1/PreviewP1
@onready var preview_p2: TextureRect = $Layout/Coluna/Centro/PainelP2/MargemP2/ColunaP2/PreviewP2
@onready var nome_p1: Label = $Layout/Coluna/Centro/PainelP1/MargemP1/ColunaP1/NomeP1
@onready var nome_p2: Label = $Layout/Coluna/Centro/PainelP2/MargemP2/ColunaP2/NomeP2
@onready var info_p1: Label = $Layout/Coluna/Centro/PainelP1/MargemP1/ColunaP1/InfoP1
@onready var info_p2: Label = $Layout/Coluna/Centro/PainelP2/MargemP2/ColunaP2/InfoP2
@onready var ready_p1: Label = $Layout/Coluna/Centro/PainelP1/MargemP1/ColunaP1/ReadyP1
@onready var ready_p2: Label = $Layout/Coluna/Centro/PainelP2/MargemP2/ColunaP2/ReadyP2
@onready var label_p2: Label = $Layout/Coluna/Centro/PainelP2/MargemP2/ColunaP2/LabelP2
@onready var linha_dificuldade: HBoxContainer = $Layout/Coluna/LinhaDificuldade
@onready var dificuldade: OptionButton = $Layout/Coluna/LinhaDificuldade/Dificuldade
@onready var countdown: Label = $Layout/Coluna/Countdown

var ids_personagens = []
var thumbnails = {}
var cursor_p1 = 0
var cursor_p2 = 1
var p1_confirmado = false
var p2_confirmado = false
var countdown_ativo = false
var tempo_countdown = 0.0
var valor_countdown = 3
var tempo_animacao = 0.0

func _ready() -> void:
	ids_personagens = DadosPersonagens.obter_ids_disponiveis()
	_carregar_thumbnails()

	cursor_p1 = max(ids_personagens.find(GameState.personagem_p1), 0)
	cursor_p2 = max(ids_personagens.find(GameState.personagem_p2), 1)

	dificuldade.clear()
	dificuldade.add_item("Easy")
	dificuldade.add_item("Medium")
	dificuldade.add_item("Hard")
	match GameState.dificuldade_ia:
		"facil":
			dificuldade.select(0)
		"dificil":
			dificuldade.select(2)
		_:
			dificuldade.select(1)

	titulo_modo.text = GameState.modo_jogo.to_upper()
	linha_dificuldade.visible = GameState.modo_jogo == "arcade"

	if GameState.modo_jogo == "arcade":
		label_p2.text = "CPU"
	elif GameState.modo_jogo == "treino":
		label_p2.text = "DUMMY"
	else:
		label_p2.text = "PLAYER 2"

	countdown.visible = false

	var largura_grade = COLUNAS * TAMANHO_CELULA.x + (COLUNAS - 1) * ESPACO
	var altura_grade = LINHAS * TAMANHO_CELULA.y + (LINHAS - 1) * ESPACO
	grade.custom_minimum_size = Vector2(largura_grade, altura_grade)
	grade.draw.connect(_desenhar_grade)

	_atualizar_previews()

func _process(delta: float) -> void:
	fundo.queue_redraw()
	tempo_animacao += delta
	grade.queue_redraw()

	if not countdown_ativo:
		return
	tempo_countdown -= delta
	if tempo_countdown > 0.0:
		return
	valor_countdown -= 1
	if valor_countdown <= 0:
		_iniciar_partida()
		return
	countdown.text = str(valor_countdown)
	tempo_countdown = 1.0

func _carregar_thumbnails() -> void:
	for id in ids_personagens:
		thumbnails[id] = DadosPersonagens.obter_preview_textura(id)

func _desenhar_grade() -> void:
	for i in ids_personagens.size():
		var col = i % COLUNAS
		var lin = i / COLUNAS
		var pos = Vector2(
			col * (TAMANHO_CELULA.x + ESPACO),
			lin * (TAMANHO_CELULA.y + ESPACO)
		)
		var rect = Rect2(pos, TAMANHO_CELULA)

		grade.draw_rect(rect, COR_CELULA)
		grade.draw_rect(rect, COR_BORDA_CELULA, false, 1.0)

		var tex = thumbnails.get(ids_personagens[i])
		if tex:
			var margem = 4.0
			var rect_thumb = Rect2(
				pos + Vector2(margem, margem),
				TAMANHO_CELULA - Vector2(margem * 2, margem * 2)
			)
			grade.draw_texture_rect(tex, rect_thumb, false)

		var nome_char = DadosPersonagens.obter_nome(ids_personagens[i])
		grade.draw_string(
			ThemeDB.fallback_font,
			pos + Vector2(TAMANHO_CELULA.x * 0.5, TAMANHO_CELULA.y - 2),
			nome_char,
			HORIZONTAL_ALIGNMENT_CENTER,
			TAMANHO_CELULA.x,
			8,
			Color(0.9, 0.85, 0.6, 0.7)
		)

	_desenhar_cursor(cursor_p1, COR_CURSOR_P1 if not p1_confirmado else COR_CONFIRMADO, false)
	_desenhar_cursor(cursor_p2, COR_CURSOR_P2 if not p2_confirmado else COR_CONFIRMADO, true)

func _desenhar_cursor(indice: int, cor: Color, eh_p2: bool) -> void:
	var col = indice % COLUNAS
	var lin = indice / COLUNAS
	var pos = Vector2(
		col * (TAMANHO_CELULA.x + ESPACO),
		lin * (TAMANHO_CELULA.y + ESPACO)
	)
	var ambos = (cursor_p1 == cursor_p2)
	var espessura = 3.0
	var fase = 0.0 if not eh_p2 else PI
	var confirmado = p2_confirmado if eh_p2 else p1_confirmado
	var pulse = 1.0 + sin(tempo_animacao * 5.0 + fase) * 0.2 if not confirmado else 1.0

	if ambos and eh_p2:
		var offset = 3.0
		grade.draw_rect(
			Rect2(pos - Vector2(-offset, -offset), TAMANHO_CELULA + Vector2(offset + 3, offset + 3)),
			cor * pulse, false, espessura
		)
	else:
		grade.draw_rect(
			Rect2(pos - Vector2(2, 2), TAMANHO_CELULA + Vector2(4, 4)),
			cor * pulse, false, espessura
		)

	var tri = 8.0
	var label_texto = "P2" if eh_p2 else "P1"
	var label_cor = cor

	if eh_p2:
		var rx = pos.x + TAMANHO_CELULA.x + 4
		var ry = pos.y + 2 if ambos else pos.y
		grade.draw_string(
			ThemeDB.fallback_font,
			Vector2(rx + 2, ry + 10),
			label_texto, HORIZONTAL_ALIGNMENT_LEFT, 30, 10, label_cor
		)
	else:
		var lx = pos.x - 4
		var ly = pos.y
		grade.draw_string(
			ThemeDB.fallback_font,
			Vector2(lx - 18, ly + 10),
			label_texto, HORIZONTAL_ALIGNMENT_RIGHT, 30, 10, label_cor
		)

func _atualizar_previews() -> void:
	var id_p1 = ids_personagens[cursor_p1]
	var id_p2 = ids_personagens[cursor_p2]
	preview_p1.texture = DadosPersonagens.obter_preview_textura(id_p1)
	preview_p2.texture = DadosPersonagens.obter_preview_textura(id_p2)
	nome_p1.text = DadosPersonagens.obter_nome(id_p1).to_upper()
	nome_p2.text = DadosPersonagens.obter_nome(id_p2).to_upper()
	var config_p1 = DadosPersonagens.obter_config(id_p1)
	var config_p2 = DadosPersonagens.obter_config(id_p2)
	info_p1.text = _gerar_texto_info(config_p1)
	info_p2.text = _gerar_texto_info(config_p2)
	ready_p1.visible = p1_confirmado
	ready_p2.visible = p2_confirmado

func _gerar_texto_info(config: Dictionary) -> String:
	var stats: Dictionary = config["stats"]
	return "HP: %d  SPD: %.1f\nATK: %d / %d" % [
		int(stats["vida"]),
		float(stats["velocidade"]),
		int(config["ataque1"]["dano"]),
		int(config["ataque2"]["dano"])
	]

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if countdown_ativo:
		return

	if event.physical_keycode == KEY_ESCAPE:
		_voltar_menu()
		accept_event()
		return

	if not p1_confirmado:
		var moveu = false
		if event.physical_keycode == KEY_A:
			cursor_p1 = _mover_cursor(cursor_p1, -1, 0)
			moveu = true
		elif event.physical_keycode == KEY_D:
			cursor_p1 = _mover_cursor(cursor_p1, 1, 0)
			moveu = true
		elif event.physical_keycode == KEY_W:
			cursor_p1 = _mover_cursor(cursor_p1, 0, -1)
			moveu = true
		elif event.physical_keycode == KEY_S:
			cursor_p1 = _mover_cursor(cursor_p1, 0, 1)
			moveu = true
		if event.physical_keycode == KEY_F or event.physical_keycode == KEY_SPACE:
			p1_confirmado = true
			if GameState.modo_jogo == "arcade" or GameState.modo_jogo == "treino":
				_sortear_inimigo()
				p2_confirmado = true
			_atualizar_previews()
			_tentar_countdown()
			accept_event()
			return
		if moveu:
			_atualizar_previews()
			accept_event()
			return
	else:
		if event.physical_keycode == KEY_G or event.physical_keycode == KEY_Q:
			p1_confirmado = false
			if GameState.modo_jogo != "versus":
				p2_confirmado = false
			countdown_ativo = false
			countdown.visible = false
			dificuldade.disabled = false
			_atualizar_previews()
			accept_event()
			return

	if GameState.modo_jogo == "versus":
		if not p2_confirmado:
			var moveu = false
			if event.physical_keycode == KEY_LEFT:
				cursor_p2 = _mover_cursor(cursor_p2, -1, 0)
				moveu = true
			elif event.physical_keycode == KEY_RIGHT:
				cursor_p2 = _mover_cursor(cursor_p2, 1, 0)
				moveu = true
			elif event.physical_keycode == KEY_UP:
				cursor_p2 = _mover_cursor(cursor_p2, 0, -1)
				moveu = true
			elif event.physical_keycode == KEY_DOWN:
				cursor_p2 = _mover_cursor(cursor_p2, 0, 1)
				moveu = true
			if event.physical_keycode == KEY_ENTER or event.physical_keycode == KEY_KP_ENTER:
				p2_confirmado = true
				_atualizar_previews()
				_tentar_countdown()
				accept_event()
				return
			if moveu:
				_atualizar_previews()
				accept_event()
				return
		else:
			if event.physical_keycode == KEY_BACKSPACE or event.physical_keycode == KEY_KP_0:
				p2_confirmado = false
				countdown_ativo = false
				countdown.visible = false
				dificuldade.disabled = false
				_atualizar_previews()
				accept_event()
				return

func _mover_cursor(indice_atual: int, dx: int, dy: int) -> int:
	var col = indice_atual % COLUNAS
	var lin = indice_atual / COLUNAS
	col = posmod(col + dx, COLUNAS)
	lin = posmod(lin + dy, LINHAS)
	var novo = lin * COLUNAS + col
	if novo >= ids_personagens.size():
		novo = ids_personagens.size() - 1
	return novo

func _tentar_countdown() -> void:
	if not p1_confirmado or not p2_confirmado:
		return
	dificuldade.disabled = true
	countdown_ativo = true
	valor_countdown = 3
	tempo_countdown = 1.0
	countdown.text = str(valor_countdown)
	countdown.visible = true

func _iniciar_partida() -> void:
	GameState.personagem_p1 = ids_personagens[cursor_p1]
	GameState.personagem_p2 = ids_personagens[cursor_p2]
	GameState.dificuldade_ia = ["facil", "medio", "dificil"][dificuldade.selected]
	GameState.resetar_rounds()
	get_tree().change_scene_to_file("res://scenes/Battle.tscn")

func _voltar_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _sortear_inimigo() -> void:
	if ids_personagens.size() <= 1:
		return
	var indice_inimigo = randi() % ids_personagens.size()
	if indice_inimigo == cursor_p1:
		indice_inimigo = (indice_inimigo + 1) % ids_personagens.size()
	cursor_p2 = indice_inimigo
	_atualizar_previews()
