extends Control

signal continuar_solicitado
signal reiniciar_solicitado
signal menu_solicitado

var botoes = []
var indice_foco = 0

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	botoes = [
		$Painel/Borda/Conteudo/Botoes/Continuar,
		$Painel/Borda/Conteudo/Botoes/Reiniciar,
		$Painel/Borda/Conteudo/Botoes/Menu
	]
	botoes[0].pressed.connect(_on_continuar_pressed)
	botoes[1].pressed.connect(_on_reiniciar_pressed)
	botoes[2].pressed.connect(_on_menu_pressed)

func abrir() -> void:
	visible = true
	indice_foco = 0
	botoes[indice_foco].grab_focus()

func fechar() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
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

func _on_continuar_pressed() -> void:
	continuar_solicitado.emit()

func _on_reiniciar_pressed() -> void:
	reiniciar_solicitado.emit()

func _on_menu_pressed() -> void:
	menu_solicitado.emit()
