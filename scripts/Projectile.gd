extends Node2D
class_name Projectile

@onready var sprite_anim: AnimatedSprite2D = $AnimatedSprite2D

const ESCALA_JS_PX = 60.0
const LIMITE_ARENA_X = 1024.0

var atacante
var atacante_id = "p1"
var dano = 0
var knockback = Vector2.ZERO
var direcao = 1
var velocidade_x = 0.0
var largura_colisao = 10.0
var altura_colisao = 10.0
var explodindo = false

func _ready() -> void:
	sprite_anim.centered = false
	sprite_anim.animation_finished.connect(_on_animation_finished)

func configurar(dados_spawn: Dictionary, novo_atacante_id: String) -> void:
	atacante = dados_spawn["atacante"]
	atacante_id = novo_atacante_id
	position = dados_spawn["posicao"]
	direcao = int(dados_spawn["direcao"])

	var dados: Dictionary = dados_spawn["dados"]
	dano = int(dados["damage"])
	knockback = dados["knockback"]
	velocidade_x = float(dados["speed"]) * ESCALA_JS_PX * float(direcao)
	largura_colisao = float(dados["collision_box"].x * dados["escala"].x)
	altura_colisao = float(dados["collision_box"].y * dados["escala"].y)

	var frames = SpriteFrames.new()
	_adicionar_animacao(frames, "move", dados["move_path"], int(dados["move_frames"]), true)
	_adicionar_animacao(frames, "explode", dados["explode_path"], int(dados["explode_frames"]), false)
	sprite_anim.sprite_frames = frames
	sprite_anim.scale = dados["escala"]
	sprite_anim.flip_h = direcao < 0
	sprite_anim.play("move")

func _process(delta: float) -> void:
	if explodindo:
		return
	position.x += velocidade_x * delta
	if position.x < -300.0 or position.x > LIMITE_ARENA_X + 300.0:
		queue_free()

func obter_retangulo() -> Rect2:
	return Rect2(global_position, Vector2(largura_colisao, altura_colisao))

func explodir() -> void:
	if explodindo:
		return
	explodindo = true
	velocidade_x = 0.0
	if sprite_anim.sprite_frames != null and sprite_anim.sprite_frames.has_animation("explode"):
		sprite_anim.play("explode")
	else:
		queue_free()

func _adicionar_animacao(sprite_frames: SpriteFrames, nome: String, caminho: String, total_frames: int, loop: bool) -> void:
	var textura = load(caminho) as Texture2D
	if textura == null:
		return
	sprite_frames.add_animation(nome)
	sprite_frames.set_animation_speed(nome, 12.0)
	sprite_frames.set_animation_loop(nome, loop)
	var largura_frame = int(textura.get_width() / max(total_frames, 1))
	var altura_frame = textura.get_height()
	for indice in total_frames:
		var atlas = AtlasTexture.new()
		atlas.atlas = textura
		atlas.region = Rect2(indice * largura_frame, 0, largura_frame, altura_frame)
		sprite_frames.add_frame(nome, atlas)

func _on_animation_finished() -> void:
	if sprite_anim.animation == "explode":
		queue_free()
