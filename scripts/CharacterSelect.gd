extends Control

@onready var label_modo: Label = $Centro/Conteudo/TituloModo
@onready var select_p1: OptionButton = $Centro/Conteudo/Infos/CardP1/ConteudoP1/SelecaoP1
@onready var select_p2: OptionButton = $Centro/Conteudo/Infos/CardP2/ConteudoP2/SelecaoP2
@onready var linha_dificuldade: HBoxContainer = $Centro/Conteudo/LinhaDificuldade
@onready var dificuldade: OptionButton = $Centro/Conteudo/LinhaDificuldade/Dificuldade
@onready var preview_p1: TextureRect = $Centro/Conteudo/Infos/CardP1/ConteudoP1/PreviewP1
@onready var preview_p2: TextureRect = $Centro/Conteudo/Infos/CardP2/ConteudoP2/PreviewP2
@onready var info_p1: Label = $Centro/Conteudo/Infos/CardP1/ConteudoP1/InfoP1
@onready var info_p2: Label = $Centro/Conteudo/Infos/CardP2/ConteudoP2/InfoP2
@onready var ready_p1: Label = $Centro/Conteudo/Infos/CardP1/ConteudoP1/ReadyP1
@onready var ready_p2: Label = $Centro/Conteudo/Infos/CardP2/ConteudoP2/ReadyP2
@onready var countdown: Label = $Centro/Conteudo/Countdown

var ids_personagens = []
var p1_confirmado = false
var p2_confirmado = false
var countdown_ativo = false
var tempo_countdown = 0.0
var valor_countdown = 3

func _ready() -> void:
	ids_personagens = DadosPersonagens.obter_ids_disponiveis()
	_popular_select(select_p1)
	_popular_select(select_p2)

	var indice_p1 = max(ids_personagens.find(GameState.personagem_p1), 0)
	var indice_p2 = max(ids_personagens.find(GameState.personagem_p2), 1)
	select_p1.select(indice_p1)
	select_p2.select(indice_p2)

	dificuldade.clear()
	dificuldade.add_item("Facil")
	dificuldade.add_item("Medio")
	dificuldade.add_item("Dificil")
	match GameState.dificuldade_ia:
		"facil":
			dificuldade.select(0)
		"dificil":
			dificuldade.select(2)
		_:
			dificuldade.select(1)

	label_modo.text = GameState.modo_jogo.to_upper()
	linha_dificuldade.visible = GameState.modo_jogo == "arcade"
	if GameState.modo_jogo == "arcade":
		$Centro/Conteudo/Infos/CardP2/ConteudoP2/LabelP2.text = "CPU"
	elif GameState.modo_jogo == "treino":
		$Centro/Conteudo/Infos/CardP2/ConteudoP2/LabelP2.text = "DUMMY"
	else:
		$Centro/Conteudo/Infos/CardP2/ConteudoP2/LabelP2.text = "PLAYER 2"

	select_p1.item_selected.connect(_atualizar_infos)
	select_p2.item_selected.connect(_atualizar_infos)
	$Centro/Conteudo/Botoes/Iniciar.pressed.connect(_on_iniciar_pressed)
	$Centro/Conteudo/Botoes/Voltar.pressed.connect(_voltar_menu)
	$Centro/Conteudo/Botoes/Iniciar.grab_focus()
	countdown.visible = false
	_atualizar_infos(0)
	_atualizar_prontos()

func _process(delta: float) -> void:
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
		if event.physical_keycode == KEY_A:
			_mover_p1(-1)
			accept_event()
			return
		if event.physical_keycode == KEY_D:
			_mover_p1(1)
			accept_event()
			return
		if event.physical_keycode == KEY_W:
			p1_confirmado = true
			if GameState.modo_jogo == "arcade" or GameState.modo_jogo == "treino":
				_sortear_inimigo()
				p2_confirmado = true
			_atualizar_prontos()
			_tentar_countdown()
			accept_event()
			return
	elif event.physical_keycode == KEY_S:
		p1_confirmado = false
		if GameState.modo_jogo == "arcade" or GameState.modo_jogo == "treino":
			p2_confirmado = false
		_atualizar_prontos()
		accept_event()
		return

	if GameState.modo_jogo == "versus":
		if not p2_confirmado:
			if event.physical_keycode == KEY_LEFT:
				_mover_p2(-1)
				accept_event()
				return
			if event.physical_keycode == KEY_RIGHT:
				_mover_p2(1)
				accept_event()
				return
			if event.physical_keycode == KEY_UP:
				p2_confirmado = true
				_atualizar_prontos()
				_tentar_countdown()
				accept_event()
				return
		elif event.physical_keycode == KEY_DOWN:
			p2_confirmado = false
			_atualizar_prontos()
			accept_event()
			return

	if event.physical_keycode == KEY_ENTER or event.physical_keycode == KEY_KP_ENTER:
		_on_iniciar_pressed()
		accept_event()

func _popular_select(select: OptionButton) -> void:
	select.clear()
	for id_personagem in ids_personagens:
		select.add_item(DadosPersonagens.obter_nome(id_personagem))

func _atualizar_infos(_indice: int) -> void:
	var config_p1 = DadosPersonagens.obter_config(ids_personagens[select_p1.selected])
	var config_p2 = DadosPersonagens.obter_config(ids_personagens[select_p2.selected])
	preview_p1.texture = DadosPersonagens.obter_preview_textura(ids_personagens[select_p1.selected])
	preview_p2.texture = DadosPersonagens.obter_preview_textura(ids_personagens[select_p2.selected])
	info_p1.text = _gerar_texto_info(config_p1)
	info_p2.text = _gerar_texto_info(config_p2)

func _gerar_texto_info(config: Dictionary) -> String:
	var stats: Dictionary = config["stats"]
	return "%s\nHP: %d | SPD: %.1f\nATK1: %d | ATK2: %d" % [
		config["nome"],
		int(stats["vida"]),
		float(stats["velocidade"]),
		int(config["ataque1"]["dano"]),
		int(config["ataque2"]["dano"])
	]

func _iniciar_partida() -> void:
	GameState.personagem_p1 = ids_personagens[select_p1.selected]
	GameState.personagem_p2 = ids_personagens[select_p2.selected]
	GameState.dificuldade_ia = ["facil", "medio", "dificil"][dificuldade.selected]
	GameState.resetar_rounds()
	get_tree().change_scene_to_file("res://scenes/Battle.tscn")

func _voltar_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_iniciar_pressed() -> void:
	p1_confirmado = true
	if GameState.modo_jogo == "arcade" or GameState.modo_jogo == "treino":
		_sortear_inimigo()
	p2_confirmado = true
	_atualizar_prontos()
	_tentar_countdown()

func _tentar_countdown() -> void:
	if not p1_confirmado or not p2_confirmado:
		return
	select_p1.disabled = true
	select_p2.disabled = true
	dificuldade.disabled = true
	countdown_ativo = true
	valor_countdown = 3
	tempo_countdown = 1.0
	countdown.text = str(valor_countdown)
	countdown.visible = true

func _atualizar_prontos() -> void:
	ready_p1.visible = p1_confirmado
	ready_p2.visible = p2_confirmado
	if not countdown_ativo:
		countdown.visible = false
		select_p1.disabled = p1_confirmado
		select_p2.disabled = p2_confirmado and GameState.modo_jogo == "versus"
		dificuldade.disabled = false

func _mover_p1(delta_indice) -> void:
	var novo_indice = posmod(select_p1.selected + delta_indice, ids_personagens.size())
	select_p1.select(novo_indice)
	_atualizar_infos(novo_indice)

func _mover_p2(delta_indice) -> void:
	var novo_indice = posmod(select_p2.selected + delta_indice, ids_personagens.size())
	select_p2.select(novo_indice)
	_atualizar_infos(novo_indice)

func _sortear_inimigo() -> void:
	if ids_personagens.size() <= 1:
		return
	var indice_inimigo = randi() % ids_personagens.size()
	if indice_inimigo == select_p1.selected:
		indice_inimigo = (indice_inimigo + 1) % ids_personagens.size()
	select_p2.select(indice_inimigo)
	_atualizar_infos(indice_inimigo)
