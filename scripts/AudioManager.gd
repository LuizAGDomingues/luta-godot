extends Node

const MIX_RATE = 44100.0

var _player_hit: AudioStreamPlayer
var _player_block: AudioStreamPlayer

func _ready() -> void:
	_player_hit = _criar_player()
	_player_block = _criar_player()

func tocar_hit() -> void:
	_tocar_buffer(_player_hit, _gerar_hit())

func tocar_bloqueio() -> void:
	_tocar_buffer(_player_block, _gerar_bloqueio())

func _criar_player() -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = MIX_RATE
	stream.buffer_length = 0.2
	player.stream = stream
	add_child(player)
	return player

func _tocar_buffer(player: AudioStreamPlayer, amostras: PackedVector2Array) -> void:
	if player == null:
		return
	player.play()
	var playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return
	for amostra in amostras:
		playback.push_frame(amostra)

func _gerar_hit() -> PackedVector2Array:
	var duracao = 0.14
	var total = int(MIX_RATE * duracao)
	var buffer = PackedVector2Array()
	buffer.resize(total)
	for i in total:
		var t = float(i) / MIX_RATE
		var env = exp(-t * 28.0)
		var ruido = randf_range(-1.0, 1.0) * env * 0.35
		buffer[i] = Vector2(ruido, ruido)
	return buffer

func _gerar_bloqueio() -> PackedVector2Array:
	var duracao = 0.10
	var total = int(MIX_RATE * duracao)
	var buffer = PackedVector2Array()
	buffer.resize(total)
	for i in total:
		var t = float(i) / MIX_RATE
		var env = exp(-t * 18.0)
		var seno = sin(TAU * 820.0 * t) * env * 0.22
		buffer[i] = Vector2(seno, seno)
	return buffer
