extends Camera2D
class_name CameraJogo

var trauma = 0.0
var decaimento_trauma = 1.8

func _process(delta: float) -> void:
	trauma = max(0.0, trauma - decaimento_trauma * delta)
	var intensidade = trauma * trauma * 18.0
	offset = Vector2(randf_range(-intensidade, intensidade), randf_range(-intensidade, intensidade))

func adicionar_trauma(valor: float) -> void:
	trauma = clampf(trauma + valor, 0.0, 1.0)
