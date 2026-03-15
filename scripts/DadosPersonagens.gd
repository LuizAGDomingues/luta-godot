extends RefCounted
class_name DadosPersonagens

const FPS_ANIMACAO = 12.0
static var _cache_offsets = {}
static var _cache_previews = {}
const ORDEM_PERSONAGENS = [
	"samurai_mack",
	"kenji",
	"evil_wizard",
	"fantasy_warrior",
	"huntress",
	"martial_hero",
	"medieval_king",
	"huntress_2"
]

const PERSONAGENS = {
	"samurai_mack": {
		"id": "samurai_mack",
		"nome": "Samurai Mack",
		"base_path": "res://assets/characters/samurai_mack",
		"escala": Vector2(2.5, 2.5),
		"offset_sprite": Vector2(211, 155),
		"sprite_face_direita": true,
		"stats": {"vida": 100, "velocidade": 5.0, "pulo": -20.0, "peso": 1.0},
		"ataque1": {"dano": 20, "knockback": Vector2(3, -2), "inicio": 3, "fim": 5, "caixa_offset": Vector2(100, 50), "caixa_tamanho": Vector2(140, 50), "cooldown_ms": 0},
		"ataque2": {"dano": 30, "knockback": Vector2(5, -4), "inicio": 2, "fim": 4, "caixa_offset": Vector2(80, 30), "caixa_tamanho": Vector2(160, 60), "cooldown_ms": 200},
		"colisao": Vector2(50, 150),
		"sprites": {
			"idle": {"arquivo": "Idle.png", "frames": 8, "loop": true},
			"run": {"arquivo": "Run.png", "frames": 8, "loop": true},
			"jump": {"arquivo": "Jump.png", "frames": 2, "loop": false},
			"fall": {"arquivo": "Fall.png", "frames": 2, "loop": false},
			"attack1": {"arquivo": "Attack1.png", "frames": 6, "loop": false},
			"attack2": {"arquivo": "Attack2.png", "frames": 6, "loop": false},
			"take_hit": {"arquivo": "Take Hit.png", "frames": 4, "loop": false},
			"death": {"arquivo": "Death.png", "frames": 6, "loop": false}
		}
	},
	"kenji": {
		"id": "kenji",
		"nome": "Kenji",
		"base_path": "res://assets/characters/kenji",
		"escala": Vector2(2.5, 2.5),
		"offset_sprite": Vector2(231, 170),
		"sprite_face_direita": false,
		"stats": {"vida": 100, "velocidade": 5.5, "pulo": -20.0, "peso": 0.9},
		"ataque1": {"dano": 18, "knockback": Vector2(3, -2), "inicio": 1, "fim": 3, "caixa_offset": Vector2(100, 50), "caixa_tamanho": Vector2(145, 50), "cooldown_ms": 0},
		"ataque2": {"dano": 28, "knockback": Vector2(5, -3), "inicio": 1, "fim": 3, "caixa_offset": Vector2(90, 30), "caixa_tamanho": Vector2(160, 60), "cooldown_ms": 200},
		"colisao": Vector2(50, 150),
		"sprites": {
			"idle": {"arquivo": "Idle.png", "frames": 4, "loop": true},
			"run": {"arquivo": "Run.png", "frames": 8, "loop": true},
			"jump": {"arquivo": "Jump.png", "frames": 2, "loop": false},
			"fall": {"arquivo": "Fall.png", "frames": 2, "loop": false},
			"attack1": {"arquivo": "Attack1.png", "frames": 4, "loop": false},
			"attack2": {"arquivo": "Attack2.png", "frames": 4, "loop": false},
			"take_hit": {"arquivo": "Take hit.png", "frames": 3, "loop": false},
			"death": {"arquivo": "Death.png", "frames": 7, "loop": false}
		}
	},
	"evil_wizard": {
		"id": "evil_wizard",
		"nome": "Evil Wizard",
		"base_path": "res://assets/characters/evil_wizard/Sprites",
		"escala": Vector2(2.5, 2.5),
		"offset_sprite": Vector2(315, 268),
		"sprite_face_direita": true,
		"stats": {"vida": 90, "velocidade": 4.5, "pulo": -19.0, "peso": 0.85},
		"ataque1": {"dano": 22, "knockback": Vector2(4, -3), "inicio": 3, "fim": 5, "caixa_offset": Vector2(100, 40), "caixa_tamanho": Vector2(150, 60), "cooldown_ms": 0},
		"ataque2": {"dano": 32, "knockback": Vector2(6, -4), "inicio": 3, "fim": 5, "caixa_offset": Vector2(90, 20), "caixa_tamanho": Vector2(170, 70), "cooldown_ms": 250},
		"colisao": Vector2(50, 150),
		"sprites": {
			"idle": {"arquivo": "Idle.png", "frames": 8, "loop": true},
			"run": {"arquivo": "Run.png", "frames": 8, "loop": true},
			"jump": {"arquivo": "Jump.png", "frames": 2, "loop": false},
			"fall": {"arquivo": "Fall.png", "frames": 2, "loop": false},
			"attack1": {"arquivo": "Attack1.png", "frames": 8, "loop": false},
			"attack2": {"arquivo": "Attack2.png", "frames": 8, "loop": false},
			"take_hit": {"arquivo": "Take hit.png", "frames": 3, "loop": false},
			"death": {"arquivo": "Death.png", "frames": 7, "loop": false}
		}
	},
	"fantasy_warrior": {
		"id": "fantasy_warrior",
		"nome": "Fantasy Warrior",
		"base_path": "res://assets/characters/fantasy_warrior/Sprites",
		"escala": Vector2(2.5, 2.5),
		"offset_sprite": Vector2(190, 102),
		"sprite_face_direita": true,
		"stats": {"vida": 110, "velocidade": 4.8, "pulo": -19.0, "peso": 1.1},
		"ataque1": {"dano": 18, "knockback": Vector2(3, -2), "inicio": 2, "fim": 4, "caixa_offset": Vector2(90, 50), "caixa_tamanho": Vector2(140, 50), "cooldown_ms": 0},
		"ataque2": {"dano": 28, "knockback": Vector2(5, -3), "inicio": 2, "fim": 4, "caixa_offset": Vector2(80, 30), "caixa_tamanho": Vector2(160, 60), "cooldown_ms": 200},
		"colisao": Vector2(50, 150),
		"sprites": {
			"idle": {"arquivo": "Idle.png", "frames": 10, "loop": true},
			"run": {"arquivo": "Run.png", "frames": 8, "loop": true},
			"jump": {"arquivo": "Jump.png", "frames": 3, "loop": false},
			"fall": {"arquivo": "Fall.png", "frames": 3, "loop": false},
			"attack1": {"arquivo": "Attack1.png", "frames": 7, "loop": false},
			"attack2": {"arquivo": "Attack2.png", "frames": 7, "loop": false},
			"take_hit": {"arquivo": "Take hit.png", "frames": 3, "loop": false},
			"death": {"arquivo": "Death.png", "frames": 7, "loop": false}
		}
	},
	"huntress": {
		"id": "huntress",
		"nome": "Huntress",
		"base_path": "res://assets/characters/huntress/Sprites",
		"escala": Vector2(2.5, 2.5),
		"offset_sprite": Vector2(168, 92),
		"sprite_face_direita": true,
		"stats": {"vida": 85, "velocidade": 6.0, "pulo": -21.0, "peso": 0.8},
		"ataque1": {"dano": 16, "knockback": Vector2(2, -2), "inicio": 2, "fim": 3, "caixa_offset": Vector2(80, 50), "caixa_tamanho": Vector2(130, 50), "cooldown_ms": 0},
		"ataque2": {"dano": 25, "knockback": Vector2(4, -3), "inicio": 2, "fim": 3, "caixa_offset": Vector2(70, 30), "caixa_tamanho": Vector2(150, 60), "cooldown_ms": 150},
		"colisao": Vector2(50, 150),
		"sprites": {
			"idle": {"arquivo": "Idle.png", "frames": 8, "loop": true},
			"run": {"arquivo": "Run.png", "frames": 8, "loop": true},
			"jump": {"arquivo": "Jump.png", "frames": 2, "loop": false},
			"fall": {"arquivo": "Fall.png", "frames": 2, "loop": false},
			"attack1": {"arquivo": "Attack1.png", "frames": 5, "loop": false},
			"attack2": {"arquivo": "Attack2.png", "frames": 5, "loop": false},
			"take_hit": {"arquivo": "Take hit.png", "frames": 3, "loop": false},
			"death": {"arquivo": "Death.png", "frames": 8, "loop": false}
		}
	},
	"martial_hero": {
		"id": "martial_hero",
		"nome": "Martial Hero",
		"base_path": "res://assets/characters/martial_hero/Sprite",
		"escala": Vector2(2.5, 2.5),
		"offset_sprite": Vector2(148, 55),
		"sprite_face_direita": true,
		"stats": {"vida": 100, "velocidade": 5.2, "pulo": -20.0, "peso": 1.0},
		"ataque1": {"dano": 20, "knockback": Vector2(3, -2), "inicio": 3, "fim": 5, "caixa_offset": Vector2(100, 50), "caixa_tamanho": Vector2(140, 50), "cooldown_ms": 0},
		"ataque2": {"dano": 30, "knockback": Vector2(5, -4), "inicio": 2, "fim": 4, "caixa_offset": Vector2(90, 30), "caixa_tamanho": Vector2(155, 60), "cooldown_ms": 200},
		"colisao": Vector2(50, 150),
		"sprites": {
			"idle": {"arquivo": "Idle.png", "frames": 10, "loop": true},
			"run": {"arquivo": "Run.png", "frames": 8, "loop": true},
			"jump": {"arquivo": "Going Up.png", "frames": 3, "loop": false},
			"fall": {"arquivo": "Going Down.png", "frames": 3, "loop": false},
			"attack1": {"arquivo": "Attack1.png", "frames": 7, "loop": false},
			"attack2": {"arquivo": "Attack2.png", "frames": 6, "loop": false},
			"take_hit": {"arquivo": "Take Hit.png", "frames": 3, "loop": false},
			"death": {"arquivo": "Death.png", "frames": 11, "loop": false}
		}
	},
	"medieval_king": {
		"id": "medieval_king",
		"nome": "Medieval King",
		"base_path": "res://assets/characters/medieval_king/Sprites",
		"escala": Vector2(2.5, 2.5),
		"offset_sprite": Vector2(174, 112),
		"sprite_face_direita": true,
		"stats": {"vida": 120, "velocidade": 4.2, "pulo": -18.0, "peso": 1.2},
		"ataque1": {"dano": 24, "knockback": Vector2(4, -2), "inicio": 1, "fim": 3, "caixa_offset": Vector2(100, 50), "caixa_tamanho": Vector2(150, 55), "cooldown_ms": 0},
		"ataque2": {"dano": 35, "knockback": Vector2(6, -4), "inicio": 1, "fim": 3, "caixa_offset": Vector2(90, 30), "caixa_tamanho": Vector2(170, 65), "cooldown_ms": 250},
		"colisao": Vector2(50, 150),
		"sprites": {
			"idle": {"arquivo": "Idle.png", "frames": 8, "loop": true},
			"run": {"arquivo": "Run.png", "frames": 8, "loop": true},
			"jump": {"arquivo": "Jump.png", "frames": 2, "loop": false},
			"fall": {"arquivo": "Fall.png", "frames": 2, "loop": false},
			"attack1": {"arquivo": "Attack1.png", "frames": 4, "loop": false},
			"attack2": {"arquivo": "Attack2.png", "frames": 4, "loop": false},
			"take_hit": {"arquivo": "Take Hit.png", "frames": 4, "loop": false},
			"death": {"arquivo": "Death.png", "frames": 6, "loop": false}
		}
	},
	"huntress_2": {
		"id": "huntress_2",
		"nome": "Huntress II",
		"base_path": "res://assets/characters/huntress_2/Sprites/Character",
		"escala": Vector2(2.5, 2.5),
		"offset_sprite": Vector2(100, 15),
		"sprite_face_direita": true,
		"stats": {"vida": 85, "velocidade": 5.5, "pulo": -21.0, "peso": 0.8},
		"ataque1": {"dano": 0, "knockback": Vector2.ZERO, "inicio": 99, "fim": 99, "caixa_offset": Vector2.ZERO, "caixa_tamanho": Vector2.ONE, "cooldown_ms": 500},
		"ataque2": {"dano": 0, "knockback": Vector2.ZERO, "inicio": 99, "fim": 99, "caixa_offset": Vector2.ZERO, "caixa_tamanho": Vector2.ONE, "cooldown_ms": 800},
		"colisao": Vector2(50, 150),
		"sprites": {
			"idle": {"arquivo": "Idle.png", "frames": 10, "loop": true},
			"run": {"arquivo": "Run.png", "frames": 8, "loop": true},
			"jump": {"arquivo": "Jump.png", "frames": 2, "loop": false},
			"fall": {"arquivo": "Fall.png", "frames": 2, "loop": false},
			"attack1": {"arquivo": "Attack.png", "frames": 6, "loop": false},
			"attack2": {"arquivo": "Attack.png", "frames": 6, "loop": false},
			"take_hit": {"arquivo": "Get Hit.png", "frames": 3, "loop": false},
			"death": {"arquivo": "Death.png", "frames": 10, "loop": false}
		},
		"projectile": {
			"move_path": "res://assets/characters/huntress_2/Sprites/Arrow/Move.png",
			"move_frames": 2,
			"explode_path": "res://assets/characters/huntress_2/Sprites/Arrow/Static.png",
			"explode_frames": 1,
			"speed": 10.0,
			"damage": 18,
			"knockback": Vector2(4, -1),
			"spawn_frame": 3,
			"spawn_offset": Vector2(90, 54),
			"escala": Vector2(3.0, 3.0),
			"collision_box": Vector2(20, 8)
		}
	}
}

static func obter_ids_disponiveis() -> Array:
	return ORDEM_PERSONAGENS.duplicate()

static func obter_config(id_personagem: String) -> Dictionary:
	return PERSONAGENS.get(id_personagem, PERSONAGENS["samurai_mack"]).duplicate(true)

static func obter_nome(id_personagem: String) -> String:
	return obter_config(id_personagem).get("nome", id_personagem)

static func calcular_offset_sprite(id_personagem: String) -> Vector2:
	if _cache_offsets.has(id_personagem):
		return _cache_offsets[id_personagem]

	var config = obter_config(id_personagem)
	var sprites: Dictionary = config.get("sprites", {})
	if not sprites.has("idle"):
		_cache_offsets[id_personagem] = Vector2(-75, -150)
		return _cache_offsets[id_personagem]

	var dados_idle: Dictionary = sprites["idle"]
	var caminho_textura = "%s/%s" % [config["base_path"], dados_idle["arquivo"]]
	var textura = load(caminho_textura) as Texture2D
	if textura == null:
		_cache_offsets[id_personagem] = Vector2(-75, -150)
		return _cache_offsets[id_personagem]

	var total_frames = int(dados_idle.get("frames", 1))
	var largura_frame = int(textura.get_width() / max(total_frames, 1))
	var altura_frame = textura.get_height()
	var colisao = config.get("colisao", Vector2(50, 150))
	var escala = config.get("escala", Vector2.ONE)
	var largura_corpo = float(colisao.x)
	var altura_corpo = float(colisao.y)
	var fallback = Vector2(
		(largura_corpo - (float(largura_frame) * float(escala.x))) * 0.5,
		altura_corpo - (float(altura_frame) * float(escala.y))
	)
	var imagem = textura.get_image()
	if imagem == null:
		_cache_offsets[id_personagem] = fallback
		return fallback

	var min_x = largura_frame
	var max_x = -1
	var max_y = -1

	for y in altura_frame:
		for x in largura_frame:
			var pixel = imagem.get_pixel(x, y)
			if pixel.a > 0.02:
				min_x = min(min_x, x)
				max_x = max(max_x, x)
				max_y = max(max_y, y)

	if max_x < 0 or max_y < 0:
		_cache_offsets[id_personagem] = fallback
		return fallback

	var centro_visivel_x = (float(min_x) + float(max_x) + 1.0) * 0.5
	var base_visivel_y = float(max_y) + 1.0
	var posicao_sprite = Vector2(
		(largura_corpo * 0.5) - (centro_visivel_x * float(escala.x)),
		altura_corpo - (base_visivel_y * float(escala.y))
	)

	_cache_offsets[id_personagem] = posicao_sprite
	return posicao_sprite

static func criar_sprite_frames(id_personagem: String) -> SpriteFrames:
	var config = obter_config(id_personagem)
	var frames = SpriteFrames.new()
	var sprites: Dictionary = config["sprites"]
	var base_path: String = config["base_path"]

	for nome_animacao in sprites.keys():
		var dados_animacao: Dictionary = sprites[nome_animacao]
		_adicionar_animacao(
			frames,
			nome_animacao,
			"%s/%s" % [base_path, dados_animacao["arquivo"]],
			int(dados_animacao["frames"]),
			bool(dados_animacao["loop"])
		)

	return frames

static func obter_preview_textura(id_personagem: String):
	if _cache_previews.has(id_personagem):
		return _cache_previews[id_personagem]

	var config = obter_config(id_personagem)
	var sprites = config.get("sprites", {})
	if not sprites.has("idle"):
		return null

	var dados_idle = sprites["idle"]
	var caminho_textura = "%s/%s" % [config["base_path"], dados_idle["arquivo"]]
	var textura = load(caminho_textura) as Texture2D
	if textura == null:
		return null

	var total_frames = int(dados_idle.get("frames", 1))
	var largura_frame = int(textura.get_width() / max(total_frames, 1))
	var altura_frame = textura.get_height()
	var atlas = AtlasTexture.new()
	atlas.atlas = textura
	atlas.region = Rect2(0, 0, largura_frame, altura_frame)
	_cache_previews[id_personagem] = atlas
	return atlas

static func _adicionar_animacao(sprite_frames: SpriteFrames, nome: String, caminho_textura: String, total_frames: int, loop: bool) -> void:
	var textura = load(caminho_textura) as Texture2D
	if textura == null:
		return

	sprite_frames.add_animation(nome)
	sprite_frames.set_animation_speed(nome, FPS_ANIMACAO)
	sprite_frames.set_animation_loop(nome, loop)

	var largura_frame = int(textura.get_width() / max(total_frames, 1))
	var altura_frame = textura.get_height()

	for indice in total_frames:
		var atlas = AtlasTexture.new()
		atlas.atlas = textura
		atlas.region = Rect2(indice * largura_frame, 0, largura_frame, altura_frame)
		sprite_frames.add_frame(nome, atlas)
