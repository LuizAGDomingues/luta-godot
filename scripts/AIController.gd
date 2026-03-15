extends RefCounted
class_name AIController

const CONFIGS = {
	"facil": {
		"tempo_reacao": 0.50,
		"chance_ataque": 0.40,
		"chance_ataque2": 0.25,
		"chance_pulo": 0.05,
		"chance_dash": 0.03,
		"alcance_ideal": 150.0
	},
	"medio": {
		"tempo_reacao": 0.30,
		"chance_ataque": 0.60,
		"chance_ataque2": 0.35,
		"chance_pulo": 0.08,
		"chance_dash": 0.08,
		"alcance_ideal": 130.0
	},
	"dificil": {
		"tempo_reacao": 0.15,
		"chance_ataque": 0.80,
		"chance_ataque2": 0.45,
		"chance_pulo": 0.12,
		"chance_dash": 0.12,
		"alcance_ideal": 115.0
	}
}

var dificuldade = "medio"
var config: Dictionary = CONFIGS["medio"]
var tempo_decisao = 0.0
var acoes_atuais = _acoes_vazias()

func _init(nova_dificuldade: String = "medio") -> void:
	dificuldade = nova_dificuldade
	config = CONFIGS.get(dificuldade, CONFIGS["medio"])

func decidir(lutador, oponente, delta: float) -> Dictionary:
	tempo_decisao -= delta
	if tempo_decisao > 0.0:
		return acoes_atuais.duplicate(true)

	tempo_decisao = float(config["tempo_reacao"])
	var acoes = _acoes_vazias()
	var delta_x = oponente.global_position.x - lutador.global_position.x
	var distancia = absf(delta_x)
	var direcao = 1
	if delta_x < 0.0:
		direcao = -1
	if distancia > float(config["alcance_ideal"]):
		if direcao < 0:
			acoes["esquerda"] = true
		else:
			acoes["direita"] = true
		if lutador.is_on_floor() and randf() < float(config["chance_pulo"]):
			acoes["pular"] = true
	else:
		if randf() < float(config["chance_ataque"]):
			if randf() < float(config["chance_ataque2"]):
				acoes["ataque2"] = true
			else:
				acoes["ataque1"] = true
		elif randf() < float(config["chance_dash"]):
			acoes["dash"] = true
			acoes["direcao_dash"] = direcao

	acoes_atuais = acoes
	return acoes_atuais.duplicate(true)

func _acoes_vazias() -> Dictionary:
	return {
		"esquerda": false,
		"direita": false,
		"pular": false,
		"ataque1": false,
		"ataque2": false,
		"dash": false,
		"direcao_dash": 0
	}
