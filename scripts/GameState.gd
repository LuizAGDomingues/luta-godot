extends Node

var modo_jogo = "versus"
var dificuldade_ia = "medio"
var personagem_p1 = "samurai_mack"
var personagem_p2 = "kenji"
var rounds_ganhos_p1 = 0
var rounds_ganhos_p2 = 0
var rounds_para_vencer = 2
var vencedor_texto = ""
var estatisticas_partida = criar_estatisticas_vazias()

func _ready() -> void:
	garantir_input_map()

func resetar_rounds() -> void:
	rounds_ganhos_p1 = 0
	rounds_ganhos_p2 = 0
	vencedor_texto = ""
	estatisticas_partida = criar_estatisticas_vazias()

func resetar_tudo() -> void:
	modo_jogo = "versus"
	dificuldade_ia = "medio"
	personagem_p1 = "samurai_mack"
	personagem_p2 = "kenji"
	resetar_rounds()

func garantir_input_map() -> void:
	_garantir_acao("p1_esquerda", KEY_A)
	_garantir_acao("p1_direita", KEY_D)
	_garantir_acao("p1_pular", KEY_W)
	_garantir_acao("p1_ataque1", KEY_SPACE)
	_garantir_acao("p1_ataque2", KEY_E)

	_garantir_acao("p2_esquerda", KEY_LEFT)
	_garantir_acao("p2_direita", KEY_RIGHT)
	_garantir_acao("p2_pular", KEY_UP)
	_garantir_acao("p2_ataque1", KEY_DOWN)
	_garantir_acao("p2_ataque2", KEY_KP_ENTER)

	_garantir_acao("pausar", KEY_ESCAPE)
	_garantir_acao("toggle_hitboxes", KEY_H)

func criar_estatisticas_vazias() -> Dictionary:
	return {
		"p1": {"dano": 0, "hits": 0, "combo_max": 0, "rounds": 0},
		"p2": {"dano": 0, "hits": 0, "combo_max": 0, "rounds": 0}
	}

func _garantir_acao(nome_acao: String, tecla: Key) -> void:
	if not InputMap.has_action(nome_acao):
		InputMap.add_action(nome_acao)

	var eventos = InputMap.action_get_events(nome_acao)
	for evento_existente in eventos:
		if evento_existente is InputEventKey and evento_existente.physical_keycode == tecla:
			return

	var evento = InputEventKey.new()
	evento.physical_keycode = tecla
	InputMap.action_add_event(nome_acao, evento)
