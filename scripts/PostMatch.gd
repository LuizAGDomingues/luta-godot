extends Control

var botoes = []
var indice_foco = 0

func _ready() -> void:
	$Centro/Painel/Conteudo/Resultado.text = GameState.vencedor_texto
	_preencher_estatisticas()
	botoes = [
		$Centro/Painel/Conteudo/Botoes/Revanche,
		$Centro/Painel/Conteudo/Botoes/Selecao,
		$Centro/Painel/Conteudo/Botoes/Menu
	]
	botoes[0].pressed.connect(_revanche)
	botoes[1].pressed.connect(_selecao)
	botoes[2].pressed.connect(_menu)
	botoes[0].grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_UP or event.physical_keycode == KEY_W:
			indice_foco = posmod(indice_foco - 1, botoes.size())
			botoes[indice_foco].grab_focus()
			accept_event()
		elif event.physical_keycode == KEY_DOWN or event.physical_keycode == KEY_S:
			indice_foco = posmod(indice_foco + 1, botoes.size())
			botoes[indice_foco].grab_focus()
			accept_event()
		elif event.physical_keycode == KEY_ENTER or event.physical_keycode == KEY_KP_ENTER or event.physical_keycode == KEY_SPACE:
			botoes[indice_foco].emit_signal("pressed")
			accept_event()

func _revanche() -> void:
	GameState.resetar_rounds()
	get_tree().change_scene_to_file("res://scenes/Battle.tscn")

func _selecao() -> void:
	GameState.resetar_rounds()
	get_tree().change_scene_to_file("res://scenes/CharacterSelect.tscn")

func _menu() -> void:
	GameState.resetar_tudo()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _preencher_estatisticas() -> void:
	var stats = GameState.estatisticas_partida
	if stats.is_empty():
		return

	$Centro/Painel/Conteudo/Stats/P1Dano.text = str(stats["p1"]["dano"])
	$Centro/Painel/Conteudo/Stats/P1Hits.text = str(stats["p1"]["hits"])
	$Centro/Painel/Conteudo/Stats/P1Combo.text = str(stats["p1"]["combo_max"])
	$Centro/Painel/Conteudo/Stats/P1Rounds.text = str(stats["p1"]["rounds"])

	$Centro/Painel/Conteudo/Stats/P2Dano.text = str(stats["p2"]["dano"])
	$Centro/Painel/Conteudo/Stats/P2Hits.text = str(stats["p2"]["hits"])
	$Centro/Painel/Conteudo/Stats/P2Combo.text = str(stats["p2"]["combo_max"])
	$Centro/Painel/Conteudo/Stats/P2Rounds.text = str(stats["p2"]["rounds"])
