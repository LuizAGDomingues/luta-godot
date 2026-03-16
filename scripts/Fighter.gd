extends CharacterBody2D
class_name Fighter

signal projetil_solicitado(dados_spawn)
signal vida_alterada(vida_atual, vida_max)
signal aterrissou(posicao)
signal dash_iniciado(posicao, direcao)

const GRAVIDADE = 2520.0
const ESCALA_JS_PX = 60.0
const VELOCIDADE_DASH = 900.0
const DURACAO_DASH = 0.15
const COOLDOWN_DASH = 0.80
const IFRAMES_DASH = 0.10
const DURACAO_HITSTUN = 0.25
const TEMPO_INVULNERAVEL = 0.15
const JANELA_DOUBLE_TAP = 0.20
const LIMITE_ARENA_X = 1024.0

enum Estado {
	PARADO,
	CORRENDO,
	PULANDO,
	CAINDO,
	ATAQUE1,
	ATAQUE2,
	LEVANDO_HIT,
	DASH,
	MORTO
}

@export var indice_jogador = 1
@export var id_personagem = "samurai_mack"

@onready var sprite_anim = $AnimatedSprite2D
@onready var colisao = $CollisionShape2D

var dados_personagem = {}
var vida_max = 100
var vida_atual = 100
var velocidade_mov = 300.0
var velocidade_pulo = -1200.0
var peso = 1.0
var largura_corpo = 50.0
var altura_corpo = 150.0
var sprite_face_direita = true

var olhando_direita = true
var estado_atual = Estado.PARADO
var atacando = false
var ataque_atual = ""
var hit_registrado = false
var dash_ativo = false
var morto = false
var projetil_disparado_no_ataque = false

var timer_dash = 0.0
var timer_cd_dash = 0.0
var timer_invulneravel = 0.0
var timer_hitstun = 0.0
var timer_cd_ataque = 0.0
var timer_flash_hit = 0.0
var timer_hit_freeze = 0.0
var estava_no_chao = true
var ultimo_toque_esquerda = -10.0
var ultimo_toque_direita = -10.0
var modo_controle = "jogador"
var acoes_ia = {
	"esquerda": false,
	"direita": false,
	"pular": false,
	"ataque1": false,
	"ataque2": false,
	"dash": false,
	"direcao_dash": 0
}
var posicao_spawn = Vector2.ZERO

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	sprite_anim.centered = false
	sprite_anim.animation_finished.connect(_on_animation_finished)
	sprite_anim.frame_changed.connect(_on_frame_changed)
	configurar_personagem(id_personagem)

func configurar_personagem(novo_id):
	id_personagem = novo_id
	dados_personagem = DadosPersonagens.obter_config(id_personagem)
	var stats = dados_personagem["stats"]
	var colisao_dados = dados_personagem["colisao"]

	vida_max = int(stats["vida"])
	vida_atual = vida_max
	velocidade_mov = float(stats["velocidade"]) * ESCALA_JS_PX
	velocidade_pulo = float(stats["pulo"]) * ESCALA_JS_PX
	peso = float(stats["peso"])
	largura_corpo = colisao_dados.x
	altura_corpo = colisao_dados.y
	sprite_face_direita = bool(dados_personagem.get("sprite_face_direita", true))

	var forma = RectangleShape2D.new()
	forma.size = Vector2(largura_corpo, altura_corpo)
	colisao.shape = forma
	colisao.position = Vector2(largura_corpo * 0.5, altura_corpo * 0.5)

	sprite_anim.sprite_frames = DadosPersonagens.criar_sprite_frames(id_personagem)
	sprite_anim.scale = dados_personagem["escala"]
	sprite_anim.position = DadosPersonagens.calcular_offset_sprite(id_personagem)
	sprite_anim.modulate = Color.WHITE
	_aplicar_flip()
	_tocar_animacao("idle")
	vida_alterada.emit(vida_atual, vida_max)

func definir_modo_controle(novo_modo):
	modo_controle = novo_modo

func definir_acoes_ia(novas_acoes):
	acoes_ia = novas_acoes.duplicate(true)

func limpar_acoes_ia() -> void:
	acoes_ia = {
		"esquerda": false,
		"direita": false,
		"pular": false,
		"ataque1": false,
		"ataque2": false,
		"dash": false,
		"direcao_dash": 0
	}

func reiniciar_em(nova_posicao):
	posicao_spawn = nova_posicao
	global_position = nova_posicao
	velocity = Vector2.ZERO
	vida_atual = vida_max
	atacando = false
	ataque_atual = ""
	hit_registrado = false
	dash_ativo = false
	morto = false
	projetil_disparado_no_ataque = false
	timer_dash = 0.0
	timer_cd_dash = 0.0
	timer_invulneravel = 0.0
	timer_hitstun = 0.0
	timer_cd_ataque = 0.0
	estado_atual = Estado.PARADO
	sprite_anim.modulate = Color.WHITE
	_tocar_animacao("idle")
	vida_alterada.emit(vida_atual, vida_max)

func _physics_process(delta):
	_atualizar_timers(delta)

	if timer_hit_freeze > 0.0:
		return

	if not esta_morto():
		_processar_controle()

	var no_chao_antes = is_on_floor()

	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0

	move_and_slide()

	if not no_chao_antes and is_on_floor() and not estava_no_chao:
		aterrissou.emit(Vector2(global_position.x + largura_corpo * 0.5, global_position.y + altura_corpo))
	estava_no_chao = is_on_floor()

	if global_position.x < 0.0:
		global_position.x = 0.0
	elif global_position.x > LIMITE_ARENA_X - largura_corpo:
		global_position.x = LIMITE_ARENA_X - largura_corpo

	if global_position.y < 0.0:
		global_position.y = 0.0
		if velocity.y < 0.0:
			velocity.y = 0.0

	_atualizar_estado()
	_atualizar_visual()

func apontar_para(posicao_x):
	olhando_direita = global_position.x < posicao_x
	_aplicar_flip()

func esta_invulneravel():
	return timer_invulneravel > 0.0

func esta_morto():
	return morto or vida_atual <= 0

func pode_registrar_hit():
	return atacando and not hit_registrado and esta_no_frame_de_hit() and int(obter_dados_ataque().get("dano", 0)) > 0

func marcar_hit_registrado():
	hit_registrado = true

func obter_retangulo_corpo():
	return Rect2(global_position, Vector2(largura_corpo, altura_corpo))

func obter_retangulo_ataque():
	var dados_ataque = obter_dados_ataque()
	var tamanho = dados_ataque.get("caixa_tamanho", Vector2.ZERO)
	var offset = dados_ataque.get("caixa_offset", Vector2.ZERO)
	if tamanho == Vector2.ZERO:
		return Rect2(global_position, Vector2.ZERO)

	var posicao_x = global_position.x + offset.x
	if not olhando_direita:
		posicao_x = global_position.x + largura_corpo - offset.x - tamanho.x
	return Rect2(Vector2(posicao_x, global_position.y + offset.y), tamanho)

func obter_dados_ataque():
	if ataque_atual == "attack2":
		return dados_personagem["ataque2"]
	return dados_personagem["ataque1"]

func receber_dano(dano, knockback):
	if esta_morto() or esta_invulneravel():
		return

	vida_atual = max(0, vida_atual - dano)
	vida_alterada.emit(vida_atual, vida_max)

	atacando = false
	ataque_atual = ""
	dash_ativo = false
	hit_registrado = false
	projetil_disparado_no_ataque = false
	timer_flash_hit = 0.12
	timer_hit_freeze = 0.04

	var direcao = 1.0
	if olhando_direita:
		direcao = -1.0
	var divisor_peso = max(peso, 0.1)
	velocity.x = (knockback.x * ESCALA_JS_PX * direcao) / divisor_peso
	velocity.y = (knockback.y * ESCALA_JS_PX) / divisor_peso

	if vida_atual <= 0:
		morto = true
		estado_atual = Estado.MORTO
		_tocar_animacao("death")
		return

	timer_hitstun = DURACAO_HITSTUN
	timer_invulneravel = TEMPO_INVULNERAVEL
	estado_atual = Estado.LEVANDO_HIT
	_tocar_animacao("take_hit")

func esta_no_frame_de_hit():
	if not atacando:
		return false
	var dados_ataque = obter_dados_ataque()
	return sprite_anim.frame >= int(dados_ataque["inicio"]) and sprite_anim.frame <= int(dados_ataque["fim"])

func _processar_controle():
	if timer_hitstun > 0.0:
		return

	var esquerda = false
	var direita = false
	var pular = false
	var ataque1 = false
	var ataque2 = false

	if modo_controle == "jogador":
		var prefixo = "p%d_" % indice_jogador
		esquerda = Input.is_action_pressed(prefixo + "esquerda")
		direita = Input.is_action_pressed(prefixo + "direita")
		pular = Input.is_action_just_pressed(prefixo + "pular")
		ataque1 = Input.is_action_just_pressed(prefixo + "ataque1")
		ataque2 = Input.is_action_just_pressed(prefixo + "ataque2")
		_processar_double_tap(prefixo)
	elif modo_controle == "ia":
		esquerda = bool(acoes_ia["esquerda"])
		direita = bool(acoes_ia["direita"])
		pular = bool(acoes_ia["pular"])
		ataque1 = bool(acoes_ia["ataque1"])
		ataque2 = bool(acoes_ia["ataque2"])
		if bool(acoes_ia["dash"]) and _pode_iniciar_dash():
			_iniciar_dash(int(acoes_ia.get("direcao_dash", 1)))
	elif modo_controle == "dummy":
		pass

	if not atacando and not dash_ativo:
		if esquerda == direita:
			velocity.x = 0.0
		elif esquerda:
			velocity.x = -velocidade_mov
		elif direita:
			velocity.x = velocidade_mov

	if pular and is_on_floor() and not atacando and not dash_ativo:
		velocity.y = velocidade_pulo

	if ataque1 and _pode_atacar():
		_iniciar_ataque("attack1")
	elif ataque2 and _pode_atacar():
		_iniciar_ataque("attack2")

	if not dash_ativo and atacando:
		velocity.x = 0.0

func _processar_double_tap(prefixo):
	var agora = Time.get_ticks_msec() / 1000.0
	if Input.is_action_just_pressed(prefixo + "esquerda"):
		if agora - ultimo_toque_esquerda <= JANELA_DOUBLE_TAP and _pode_iniciar_dash():
			_iniciar_dash(-1)
		ultimo_toque_esquerda = agora
	if Input.is_action_just_pressed(prefixo + "direita"):
		if agora - ultimo_toque_direita <= JANELA_DOUBLE_TAP and _pode_iniciar_dash():
			_iniciar_dash(1)
		ultimo_toque_direita = agora

func _pode_iniciar_dash():
	return not dash_ativo and not atacando and timer_cd_dash <= 0.0 and not esta_morto()

func _iniciar_dash(direcao):
	dash_ativo = true
	timer_dash = DURACAO_DASH
	timer_cd_dash = COOLDOWN_DASH
	timer_invulneravel = max(timer_invulneravel, IFRAMES_DASH)
	velocity.x = VELOCIDADE_DASH * float(direcao)
	dash_iniciado.emit(Vector2(global_position.x + largura_corpo * 0.5, global_position.y + altura_corpo), direcao)

func _pode_atacar():
	return not esta_morto() and not atacando and not dash_ativo and timer_cd_ataque <= 0.0

func _iniciar_ataque(nome_ataque):
	ataque_atual = nome_ataque
	atacando = true
	hit_registrado = false
	projetil_disparado_no_ataque = false
	velocity.x = 0.0
	var dados_ataque = dados_personagem["ataque1"]
	if nome_ataque == "attack2":
		dados_ataque = dados_personagem["ataque2"]
	timer_cd_ataque = float(dados_ataque["cooldown_ms"]) / 1000.0
	_tocar_animacao(nome_ataque)

func _atualizar_timers(delta):
	timer_dash = max(0.0, timer_dash - delta)
	timer_cd_dash = max(0.0, timer_cd_dash - delta)
	timer_invulneravel = max(0.0, timer_invulneravel - delta)
	timer_hitstun = max(0.0, timer_hitstun - delta)
	timer_cd_ataque = max(0.0, timer_cd_ataque - delta)
	timer_flash_hit = max(0.0, timer_flash_hit - delta)
	timer_hit_freeze = max(0.0, timer_hit_freeze - delta)

	if dash_ativo:
		if timer_dash <= 0.0:
			dash_ativo = false
		else:
			velocity.y = 0.0

func _atualizar_estado():
	if esta_morto():
		estado_atual = Estado.MORTO
	elif timer_hitstun > 0.0:
		estado_atual = Estado.LEVANDO_HIT
	elif dash_ativo:
		estado_atual = Estado.DASH
	elif atacando:
		if ataque_atual == "attack2":
			estado_atual = Estado.ATAQUE2
		else:
			estado_atual = Estado.ATAQUE1
	elif not is_on_floor():
		if velocity.y < 0.0:
			estado_atual = Estado.PULANDO
		else:
			estado_atual = Estado.CAINDO
	elif absf(velocity.x) > 0.1:
		estado_atual = Estado.CORRENDO
	else:
		estado_atual = Estado.PARADO

func _atualizar_visual():
	match estado_atual:
		Estado.PARADO:
			_tocar_animacao("idle")
		Estado.CORRENDO:
			_tocar_animacao("run")
		Estado.PULANDO:
			_tocar_animacao("jump")
		Estado.CAINDO:
			_tocar_animacao("fall")
		Estado.DASH:
			_tocar_animacao("run")
		Estado.LEVANDO_HIT:
			if sprite_anim.animation != "take_hit":
				_tocar_animacao("take_hit")
		Estado.MORTO:
			if sprite_anim.animation != "death":
				_tocar_animacao("death")

	var cor = Color.WHITE
	if timer_flash_hit > 0.0:
		var t = timer_flash_hit / 0.12
		cor = Color(1.0, 1.0, 1.0).lerp(Color.WHITE, 1.0 - t)
		sprite_anim.material = _obter_material_flash(t)
	else:
		sprite_anim.material = null
		if timer_invulneravel > 0.0:
			if int(Time.get_ticks_msec() / 60) % 2 == 0:
				cor.a = 0.6
			else:
				cor.a = 0.9
	sprite_anim.modulate = cor
	_aplicar_flip()

func _aplicar_flip():
	sprite_anim.flip_h = olhando_direita != sprite_face_direita

func _tocar_animacao(nome_animacao):
	if sprite_anim.sprite_frames == null:
		return
	if not sprite_anim.sprite_frames.has_animation(nome_animacao):
		return
	if sprite_anim.animation != nome_animacao:
		sprite_anim.play(nome_animacao)
	elif not sprite_anim.is_playing():
		sprite_anim.play()

func _on_animation_finished():
	if sprite_anim.animation == "attack1" or sprite_anim.animation == "attack2":
		atacando = false
		ataque_atual = ""
		hit_registrado = false
		projetil_disparado_no_ataque = false
	elif sprite_anim.animation == "take_hit":
		timer_hitstun = 0.0
	elif sprite_anim.animation == "death":
		sprite_anim.stop()

func _on_frame_changed():
	if not atacando:
		return
	if not dados_personagem.has("projectile"):
		return
	if projetil_disparado_no_ataque:
		return

	var dados_proj = dados_personagem["projectile"]
	if sprite_anim.frame != int(dados_proj["spawn_frame"]):
		return

	projetil_disparado_no_ataque = true
	var direcao = -1
	if olhando_direita:
		direcao = 1
	var tamanho_proj = dados_proj["collision_box"] * dados_proj["escala"]
	var spawn_offset = dados_proj["spawn_offset"]
	var spawn_x = global_position.x + spawn_offset.x
	if direcao < 0:
		spawn_x = global_position.x + largura_corpo - spawn_offset.x - tamanho_proj.x
	var dados_spawn = {
		"posicao": Vector2(spawn_x, global_position.y + spawn_offset.y),
		"direcao": direcao,
		"dados": dados_proj.duplicate(true),
		"atacante": self
	}
	projetil_solicitado.emit(dados_spawn)

static var _material_flash: ShaderMaterial = null

static func _obter_material_flash(intensidade: float) -> ShaderMaterial:
	if _material_flash == null:
		var shader = Shader.new()
		shader.code = """
shader_type canvas_item;
uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
void fragment() {
	vec4 cor = texture(TEXTURE, UV);
	cor.rgb = mix(cor.rgb, vec3(1.0), flash_amount);
	COLOR = cor;
}
"""
		_material_flash = ShaderMaterial.new()
		_material_flash.shader = shader
	_material_flash.set_shader_parameter("flash_amount", intensidade * 0.7)
	return _material_flash
