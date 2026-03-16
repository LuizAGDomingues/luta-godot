extends Control

var botoes = []
var indice_foco = 0
var timer_anim = 0.0

@onready var fundo = $Fundo
@onready var titulo = $Centro/Layout/Titulo
@onready var subtitulo = $Centro/Layout/Subtitulo
@onready var container_botoes = $Centro/Layout/Botoes

func _ready() -> void:
	GameState.garantir_input_map()
	botoes = [
		container_botoes.get_node("Versus"),
		container_botoes.get_node("Arcade"),
		container_botoes.get_node("Treino")
	]
	botoes[0].pressed.connect(_iniciar_versus)
	botoes[1].pressed.connect(_iniciar_arcade)
	botoes[2].pressed.connect(_iniciar_treino)
	botoes[0].grab_focus()

func _process(delta: float) -> void:
	timer_anim += delta
	fundo.queue_redraw()

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

func _iniciar_versus() -> void:
	GameState.modo_jogo = "versus"
	GameState.resetar_rounds()
	get_tree().change_scene_to_file("res://scenes/CharacterSelect.tscn")

func _iniciar_arcade() -> void:
	GameState.modo_jogo = "arcade"
	GameState.resetar_rounds()
	get_tree().change_scene_to_file("res://scenes/CharacterSelect.tscn")

func _iniciar_treino() -> void:
	GameState.modo_jogo = "treino"
	GameState.resetar_rounds()
	get_tree().change_scene_to_file("res://scenes/CharacterSelect.tscn")
