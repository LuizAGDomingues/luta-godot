extends Node2D

const TEMPO_PARTIDA = 90.0
const CENA_PROJETIL = preload("res://scenes/Projectile.tscn")

@onready var fighter1 = $Fighter1
@onready var fighter2 = $Fighter2
@onready var hud = $HUD
@onready var camera = $Camera2D
@onready var musica = $Musica
@onready var projetis = $Projetis
@onready var pause_menu = $PauseMenu
@onready var efeitos = $Efeitos

var tempo_restante = TEMPO_PARTIDA
var luta_encerrando = false
var round_em_transicao = false
var round_iniciando = true
var em_treino = false
var ia_controller = null
var mostrar_hitboxes = false
var estatisticas = {}
var timer_ready = 0.0
var fase_ready = 0

func _ready():
	randomize()
	CombatSystem.reiniciar()
	em_treino = GameState.modo_jogo == "treino"
	camera.position = Vector2(512, 288)
	mostrar_hitboxes = false
	estatisticas = GameState.criar_estatisticas_vazias()

	fighter1.indice_jogador = 1
	fighter2.indice_jogador = 2
	fighter1.configurar_personagem(GameState.personagem_p1)
	fighter2.configurar_personagem(GameState.personagem_p2)
	fighter1.reiniciar_em(Vector2(250, 330))
	fighter2.reiniciar_em(Vector2(774, 330))
	fighter1.apontar_para(fighter2.global_position.x)
	fighter2.apontar_para(fighter1.global_position.x)

	fighter1.definir_modo_controle("jogador")
	match GameState.modo_jogo:
		"arcade":
			fighter2.definir_modo_controle("ia")
			ia_controller = AIController.new(GameState.dificuldade_ia)
		"treino":
			fighter2.definir_modo_controle("dummy")
		_:
			fighter2.definir_modo_controle("jogador")

	fighter1.projetil_solicitado.connect(_on_fighter1_projetil_solicitado)
	fighter2.projetil_solicitado.connect(_on_fighter2_projetil_solicitado)
	fighter1.aterrissou.connect(_on_aterrissagem)
	fighter2.aterrissou.connect(_on_aterrissagem)
	fighter1.dash_iniciado.connect(_on_dash)
	fighter2.dash_iniciado.connect(_on_dash)
	CombatSystem.hit_acertado.connect(_on_hit_acertado)
	pause_menu.continuar_solicitado.connect(_retomar_jogo)
	pause_menu.reiniciar_solicitado.connect(_reiniciar_partida)
	pause_menu.menu_solicitado.connect(_voltar_menu)
	hud.configurar(fighter1, fighter2, em_treino)
	hud.atualizar_rounds(GameState.rounds_ganhos_p1, GameState.rounds_ganhos_p2, GameState.rounds_para_vencer)
	hud.atualizar_timer(tempo_restante)
	pause_menu.visible = false

	round_iniciando = true
	fase_ready = 0
	timer_ready = 0.8
	hud.mostrar_texto("READY")

	if musica.stream == null:
		musica.stream = load("res://assets/audio/Perimore.mp3")
	if musica.stream != null:
		musica.play()

func _process(delta):
	if Input.is_action_just_pressed("pausar") and not luta_encerrando and not round_em_transicao and not round_iniciando:
		_alternar_pausa()
	if em_treino and Input.is_action_just_pressed("toggle_hitboxes"):
		mostrar_hitboxes = not mostrar_hitboxes
	queue_redraw()

	if get_tree().paused:
		return

	if round_iniciando:
		_processar_ready_fight(delta)
		return

	if round_em_transicao or luta_encerrando:
		return

	if GameState.modo_jogo == "arcade" and ia_controller != null:
		fighter2.definir_acoes_ia(ia_controller.decidir(fighter2, fighter1, delta))
	else:
		fighter2.limpar_acoes_ia()

	CombatSystem.atualizar(delta)
	fighter1.apontar_para(fighter2.global_position.x)
	fighter2.apontar_para(fighter1.global_position.x)

	if not em_treino and not round_em_transicao and not luta_encerrando:
		tempo_restante = max(0.0, tempo_restante - delta)
		hud.atualizar_timer(tempo_restante)
		if tempo_restante <= 0.0:
			_encerrar_round_por_tempo()
			return
	else:
		hud.atualizar_timer(tempo_restante)

	_verificar_ataques()
	_verificar_projeteis()

	if em_treino:
		if fighter2.vida_atual < fighter2.vida_max:
			fighter2.vida_atual = fighter2.vida_max
			fighter2.vida_alterada.emit(fighter2.vida_atual, fighter2.vida_max)
		if fighter1.esta_morto():
			_reiniciar_round()
	elif not luta_encerrando and not round_em_transicao:
		if fighter1.esta_morto() or fighter2.esta_morto():
			_encerrar_round_por_vida()

func _verificar_ataques():
	_resolver_ataque(fighter1, fighter2, "p1")
	_resolver_ataque(fighter2, fighter1, "p2")

func _resolver_ataque(atacante, defensor, chave):
	if not atacante.pode_registrar_hit():
		return
	if not atacante.obter_retangulo_ataque().intersects(defensor.obter_retangulo_corpo()):
		return

	var resultado = CombatSystem.processar_hit(atacante, defensor, atacante.obter_dados_ataque(), chave)
	if bool(resultado.get("cancelado", false)):
		return

	atacante.marcar_hit_registrado()
	var combo = int(resultado["combo"])
	_registrar_hit(chave, int(resultado["dano"]), combo)
	hud.exibir_numero_dano(defensor.global_position + Vector2(defensor.largura_corpo * 0.5, -12), int(resultado["dano"]), combo)
	hud.atualizar_combo(chave, combo)
	AudioManager.tocar_hit()
	if combo < 2:
		camera.adicionar_trauma(0.22)
	else:
		camera.adicionar_trauma(0.35)

func _verificar_projeteis():
	for filho in projetis.get_children():
		var projetil = filho
		if projetil == null or projetil.explodindo:
			continue

		var alvo = fighter1
		if projetil.atacante_id == "p1":
			alvo = fighter2
		if not projetil.obter_retangulo().intersects(alvo.obter_retangulo_corpo()):
			continue

		var dados_ataque = {"dano": projetil.dano, "knockback": projetil.knockback}
		var resultado = CombatSystem.processar_hit(projetil.atacante, alvo, dados_ataque, projetil.atacante_id)
		if bool(resultado.get("cancelado", false)):
			continue

		projetil.explodir()
		var combo_proj = int(resultado["combo"])
		_registrar_hit(projetil.atacante_id, int(resultado["dano"]), combo_proj)
		hud.exibir_numero_dano(alvo.global_position + Vector2(alvo.largura_corpo * 0.5, -18), int(resultado["dano"]), combo_proj)
		hud.atualizar_combo(projetil.atacante_id, combo_proj)
		AudioManager.tocar_hit()
		camera.adicionar_trauma(0.22)

func _encerrar_round_por_tempo():
	if round_em_transicao or luta_encerrando:
		return
	if fighter1.vida_atual == fighter2.vida_atual:
		_iniciar_transicao_round("Tempo esgotado")
	elif fighter1.vida_atual > fighter2.vida_atual:
		registrar_vitoria(1)
	else:
		registrar_vitoria(2)

func _encerrar_round_por_vida():
	if round_em_transicao or luta_encerrando:
		return
	if fighter1.esta_morto() and fighter2.esta_morto():
		_iniciar_transicao_round("Empate")
	elif fighter2.esta_morto():
		registrar_vitoria(1)
	else:
		registrar_vitoria(2)

func registrar_vitoria(indice_vencedor):
	if indice_vencedor == 1:
		GameState.rounds_ganhos_p1 += 1
		estatisticas["p1"]["rounds"] = int(estatisticas["p1"]["rounds"]) + 1
		_iniciar_transicao_round("%s venceu o round" % DadosPersonagens.obter_nome(fighter1.id_personagem))
	else:
		GameState.rounds_ganhos_p2 += 1
		estatisticas["p2"]["rounds"] = int(estatisticas["p2"]["rounds"]) + 1
		_iniciar_transicao_round("%s venceu o round" % DadosPersonagens.obter_nome(fighter2.id_personagem))
	hud.atualizar_rounds(GameState.rounds_ganhos_p1, GameState.rounds_ganhos_p2, GameState.rounds_para_vencer)

func _iniciar_transicao_round(texto):
	round_em_transicao = true
	hud.mostrar_texto(texto)
	call_deferred("_finalize_transicao_round")

func _finalize_transicao_round():
	await get_tree().create_timer(2.0).timeout
	if em_treino:
		_reiniciar_round()
		return
	if GameState.rounds_ganhos_p1 >= GameState.rounds_para_vencer:
		_encerrar_partida(DadosPersonagens.obter_nome(fighter1.id_personagem))
	elif GameState.rounds_ganhos_p2 >= GameState.rounds_para_vencer:
		_encerrar_partida(DadosPersonagens.obter_nome(fighter2.id_personagem))
	else:
		_reiniciar_round()

func _reiniciar_round():
	round_em_transicao = false
	tempo_restante = TEMPO_PARTIDA
	CombatSystem.reiniciar()
	for filho in projetis.get_children():
		filho.queue_free()
	fighter1.reiniciar_em(Vector2(250, 330))
	fighter2.reiniciar_em(Vector2(774, 330))
	fighter1.apontar_para(fighter2.global_position.x)
	fighter2.apontar_para(fighter1.global_position.x)
	hud.atualizar_rounds(GameState.rounds_ganhos_p1, GameState.rounds_ganhos_p2, GameState.rounds_para_vencer)
	hud.atualizar_timer(tempo_restante)
	round_iniciando = true
	fase_ready = 0
	timer_ready = 0.8
	hud.mostrar_texto("READY")

func _encerrar_partida(nome_vencedor):
	if luta_encerrando:
		return
	luta_encerrando = true
	GameState.vencedor_texto = "%s venceu a partida" % nome_vencedor
	GameState.estatisticas_partida = estatisticas.duplicate(true)
	hud.mostrar_texto(GameState.vencedor_texto)
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/PostMatch.tscn")

func _on_fighter1_projetil_solicitado(dados_spawn):
	_criar_projetil(dados_spawn, "p1")

func _on_fighter2_projetil_solicitado(dados_spawn):
	_criar_projetil(dados_spawn, "p2")

func _criar_projetil(dados_spawn, atacante_id):
	var projetil = CENA_PROJETIL.instantiate()
	projetis.add_child(projetil)
	projetil.configurar(dados_spawn, atacante_id)

func _alternar_pausa():
	if get_tree().paused:
		_retomar_jogo()
	else:
		get_tree().paused = true
		pause_menu.abrir()

func _retomar_jogo():
	pause_menu.fechar()
	get_tree().paused = false

func _voltar_menu():
	get_tree().paused = false
	GameState.resetar_tudo()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _reiniciar_partida():
	get_tree().paused = false
	GameState.resetar_rounds()
	get_tree().change_scene_to_file("res://scenes/Battle.tscn")

func _registrar_hit(chave, dano, combo):
	if not estatisticas.has(chave):
		return
	estatisticas[chave]["dano"] = int(estatisticas[chave]["dano"]) + dano
	estatisticas[chave]["hits"] = int(estatisticas[chave]["hits"]) + 1
	if combo > int(estatisticas[chave]["combo_max"]):
		estatisticas[chave]["combo_max"] = combo

func _processar_ready_fight(delta):
	timer_ready -= delta
	if timer_ready <= 0.0:
		fase_ready += 1
		if fase_ready == 1:
			hud.mostrar_texto("FIGHT!")
			timer_ready = 0.6
		else:
			hud.esconder_texto()
			round_iniciando = false

func _on_aterrissagem(posicao: Vector2) -> void:
	if efeitos != null:
		efeitos.criar_poeira_aterrissagem(posicao)

func _on_dash(posicao: Vector2, direcao: int) -> void:
	if efeitos != null:
		efeitos.criar_poeira_dash(posicao, direcao)

func _on_hit_acertado(_atacante, defensor, _dano, combo) -> void:
	if efeitos != null and defensor != null:
		var pos_hit = defensor.global_position + Vector2(defensor.largura_corpo * 0.5, defensor.altura_corpo * 0.4)
		efeitos.criar_hit_sparks(pos_hit, combo)

func _draw():
	if not em_treino or not mostrar_hitboxes:
		return
	_desenhar_hitbox_lutador(fighter1, Color(0.1, 1.0, 0.1, 0.9), Color(1.0, 0.1, 0.1, 0.9))
	_desenhar_hitbox_lutador(fighter2, Color(0.1, 1.0, 0.1, 0.9), Color(1.0, 0.1, 0.1, 0.9))
	for filho in projetis.get_children():
		if filho == null:
			continue
		draw_rect(filho.obter_retangulo(), Color(1.0, 0.9, 0.2, 0.35), true)
		draw_rect(filho.obter_retangulo(), Color(1.0, 0.9, 0.2, 0.9), false, 2.0)

func _desenhar_hitbox_lutador(lutador, cor_corpo, cor_ataque):
	if lutador == null or lutador.esta_morto():
		return
	var corpo = lutador.obter_retangulo_corpo()
	draw_rect(corpo, Color(cor_corpo.r, cor_corpo.g, cor_corpo.b, 0.18), true)
	draw_rect(corpo, cor_corpo, false, 2.0)
	if lutador.pode_registrar_hit():
		var ataque = lutador.obter_retangulo_ataque()
		draw_rect(ataque, Color(cor_ataque.r, cor_ataque.g, cor_ataque.b, 0.18), true)
		draw_rect(ataque, cor_ataque, false, 2.0)
