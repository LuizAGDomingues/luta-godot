extends Node

signal hit_acertado(atacante, defensor, dano, combo)

const JANELA_COMBO = 1.5
const COMBO_DAMAGE_SCALING = 0.1
const COMBO_DAMAGE_CAP = 2.0

var combos = {
	"p1": {"count": 0, "timer": 0.0},
	"p2": {"count": 0, "timer": 0.0}
}

func atualizar(delta):
	for chave in combos.keys():
		var combo = combos[chave]
		if combo["timer"] > 0.0:
			combo["timer"] = max(0.0, combo["timer"] - delta)
			if combo["timer"] <= 0.0:
				combo["count"] = 0

func reiniciar():
	for chave in combos.keys():
		combos[chave]["count"] = 0
		combos[chave]["timer"] = 0.0

func obter_combo(chave):
	var combo = combos.get(chave, {"count": 0})
	return int(combo["count"])

func processar_hit(atacante, defensor, dados_ataque, chave_atacante):
	if defensor == null or atacante == null:
		return {"cancelado": true}
	if defensor.has_method("esta_morto") and defensor.esta_morto():
		return {"cancelado": true}
	if defensor.has_method("esta_invulneravel") and defensor.esta_invulneravel():
		return {"cancelado": true}

	var dano_base = int(dados_ataque.get("dano", 0))
	var knockback_base = dados_ataque.get("knockback", Vector2.ZERO)
	var dano_final = dano_base
	var knockback_final = knockback_base
	var combo_atual = 0

	var combo = combos.get(chave_atacante, {"count": 0, "timer": 0.0})
	combo["count"] = int(combo["count"]) + 1
	combo["timer"] = JANELA_COMBO
	combo_atual = int(combo["count"])
	var multiplicador = min(1.0 + max(combo_atual - 1, 0) * COMBO_DAMAGE_SCALING, COMBO_DAMAGE_CAP)
	dano_final = int(round(dano_base * multiplicador))

	if defensor.has_method("receber_dano"):
		defensor.receber_dano(dano_final, knockback_final)

	hit_acertado.emit(atacante, defensor, dano_final, combo_atual)
	return {
		"cancelado": false,
		"dano": dano_final,
		"combo": combo_atual,
		"tipo": "hit"
	}
