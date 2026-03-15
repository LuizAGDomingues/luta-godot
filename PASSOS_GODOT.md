# PASSOS_GODOT.md

> Passo-a-passo do que ainda precisa ser validado ou ajustado no editor
> Godot 4.6.1 para continuar a migracao.

---

## 1. Abrir o projeto

1. Abra o Godot 4.6.1.
2. Importe/abra a pasta:
   `C:\Users\luiza\OneDrive\Área de Trabalho\projetos godot\luta-godot`
3. Espere o editor reimportar os assets novos.

Resultado esperado:

- o projeto abre sem converter nada estranho
- `assets/stage/` e `assets/ui/` aparecem no sistema de arquivos
- `scenes/` e `scripts/` aparecem normalmente

---

## 2. Conferir configuracao do projeto

Em `Projeto -> Configuracoes do Projeto`, confira:

- cena principal:
  `res://scenes/MainMenu.tscn`
- viewport:
  - largura `1024`
  - altura `576`
- stretch:
  - mode `canvas_items`
  - aspect `keep`
- autoloads:
  - `GameState`
  - `CombatSystem`
  - `AudioManager`

---

## 3. Abrir as cenas principais

Abra, nesta ordem:

1. `scenes/MainMenu.tscn`
2. `scenes/CharacterSelect.tscn`
3. `scenes/Battle.tscn`
4. `scenes/PostMatch.tscn`
5. `scenes/ui/HUD.tscn`

Se o Godot acusar erro:

1. copie o texto exato
2. informe arquivo e linha
3. diga em qual cena isso aconteceu

---

## 4. Validar o fluxo principal

Rode com `F5` e teste:

1. menu principal
2. selecao
3. batalha
4. pos-partida

Resultado esperado:

- menu abre com logo e layout em duas colunas
- selecao abre com dois paines de preview
- batalha abre com cenario do JS
- HUD aparece no topo
- personagens aparecem e se movem
- musica toca

---

## 5. Testar combate base

Teste primeiro:

- `Samurai Mack` vs `Kenji`

Confirme:

- P1 move com `A/D`
- P1 pula com `W`
- P1 usa `Space` e `E`
- P2 move com setas
- P2 pula com seta para cima
- P2 usa seta para baixo e `Numpad Enter`
- dash por double-tap funciona
- ataques tiram vida
- round termina
- partida vai para `PostMatch`

---

## 6. Testar modos

### Arcade

1. abra `Arcade`
2. escolha personagens
3. escolha dificuldade
4. inicie

Confirme se a IA se move e ataca.

### Treino

1. abra `Treino`
2. escolha personagens
3. inicie

Confirme se:

- o P2 fica como dummy
- o timer mostra `TREINO`
- a vida do dummy volta
- `H` alterna hitboxes

---

## 7. Testar projetil

Use `Huntress II` em um dos lados.

Confirme:

- o projetil nasce no ataque
- vai na direcao correta
- acerta o oponente
- causa dano
- entra em explosao

Se nascer em lugar estranho, revisar em `scripts/DadosPersonagens.gd`:

- `spawn_offset`
- `collision_box`
- `escala`

---

## 8. Testar visual das telas

Comparar com o projeto JS:

- `index.html`
- `src/css/menu.css`
- `src/css/battle.css`

Telas para revisar:

- `MainMenu`
- `CharacterSelect`
- `HUD`
- `PostMatch`

Se algo estiver muito diferente, registrar:

1. print da tela
2. o que esta diferente
3. se o problema e estrutura, alinhamento, cor, fonte ou comportamento

---

## 9. Ajustes provaveis no editor

Pontos que podem precisar refinamento visual/manual:

- tamanho de labels e fontes
- margens e espacamentos das telas
- preenchimento das barras de vida
- ordem visual de elementos do HUD
- escala/offset de previews
- escala/offset de alguns personagens

Pontos provaveis de ajuste em codigo:

- `scripts/DadosPersonagens.gd`
- `scripts/HUD.gd`
- `scripts/CharacterSelect.gd`
- `scripts/BattleScene.gd`

---

## 10. Prioridade pratica de continuidade

Se tudo abrir, a ordem recomendada de continuidade e:

1. fechar o visual do menu
2. fechar o visual da selecao
3. fechar o HUD
4. revisar pos-partida
5. revisar comportamento fino dos personagens
6. portar mais polish do JS
