# PROJETO.md - Estado Real do Projeto

> Documento canonico de contexto para este workspace.
> Atualizado em: 16/03/2026.
> Se este arquivo divergir do codigo, o codigo vence.

---

## 1. Objetivo

Estamos migrando o jogo de luta 2D em JavaScript/Canvas para Godot 4.6.1
usando GDScript.

Este arquivo existe para registrar:

- o estado real do projeto JS
- o estado real do projeto Godot
- o que ja foi portado
- o que ainda falta para aproximar do original

Nao serve para descrever um plano idealizado como se tudo ja estivesse
pronto.

---

## 2. Fontes de Verdade

### Projeto de origem

- GitHub: <https://github.com/LuizAGDomingues/js-fighting-game>
- Caminho local:
  `C:\Users\luiza\OneDrive\Área de Trabalho\projeto\2d-fightgame`

### Projeto Godot

- Caminho local:
  `C:\Users\luiza\OneDrive\Área de Trabalho\projetos godot\luta-godot`

### Prioridade de confianca

Quando houver conflito entre fontes, usar esta ordem:

1. codigo JS real em `src/`
2. codigo/cenas atuais do Godot em `scripts/` e `scenes/`
3. assets realmente presentes em disco
4. documentacao historica

Observacao:

- a documentacao antiga do workspace estava desalinhada
- este arquivo deve ser mantido alinhado com o codigo atual

---

## 3. Estado Atual do Projeto Godot

Hoje o projeto Godot ja tem uma base funcional jogavel com visual
redesenhado no estilo Street Fighter / arcade fighting game.

### Estado geral

- Godot alvo: `4.6.1 stable`
- cena principal: `res://scenes/MainMenu.tscn`
- viewport: `1024x576`
- stretch mode: `canvas_items`
- stretch aspect: `keep`
- autoloads:
  - `GameState`
  - `CombatSystem`
  - `AudioManager`

### Fluxo atual ja existente

- menu principal
- selecao de personagem
- batalha (com sequencia READY / FIGHT!)
- pausa
- pos-partida

### Features implementadas

#### Combate

- movimentacao lateral com velocidade por personagem
- pulo e gravidade
- dash por double-tap (com invulnerabilidade e cooldown)
- `attack1` e `attack2` com dano, knockback e frame windows distintos
- hit detection por retangulos (corpo e ataque)
- hitstun e invulnerabilidade curta pos-dano
- combo system com janela de 1.5s e damage scaling (+10% por hit, cap 2.0x)
- projetil para `huntress_2` (spawn, colisao, explosao)
- rounds com timer (90s) e best-of-N configuravel
- modos versus, arcade (IA com 3 dificuldades) e treino (dummy auto-heal)

#### Visual e feedback

- HUD estilo Street Fighter com barras de vida anguladas (custom draw)
  - barras em paralelogramo com cor que transiciona de dourado para vermelho
  - trail de dano vermelho (lerp mais lento mostrando dano recente)
  - highlight/brilho no topo das barras
  - timer em caixa octogonal com borda dourada
  - round dots estilizados (dourado cheio / cinza vazio)
- combo display dedicado por jogador ("X HITS" com escala animada)
- numeros de dano flutuantes (tamanho/cor escalam com combo)
- particulas de hit (sparks com cor escalando por combo: amarelo → laranja → vermelho)
- poeira de aterrissagem e dash
- flash branco ao receber dano (shader canvas_item)
- hit freeze frame curto (40ms) para feedback de impacto
- camera shake baseado em trauma (mais forte em combos)
- sequencia READY / FIGHT! no inicio de cada round

#### UI / telas

- menu principal com tema vermelho/dourado/preto e fundo animado (faixas diagonais)
- selecao de personagem com cards P1 (azul) / P2 (vermelho), VS central, previews
- pos-partida com stats comparativas P1 vs P2 e botoes estilizados
- pausa com overlay escuro e painel consistente com o tema
- navegacao por teclado em todas as telas (W/S ou setas + Enter/Space)
- confirmacao por teclado na selecao com countdown

#### Audio

- musica de batalha (Perimore.mp3)
- efeitos sonoros sintetizados proceduralmente (hit, bloqueio) via AudioStreamGenerator

#### Debug

- hitboxes visiveis no treino com tecla `H`

### Decisoes de design

- nao existe mecanica de bloqueio no Godot (removida por decisao)
- alinhamento de sprite usa bounding box visivel do primeiro frame do idle
- nomes internos seguem PT-BR nos scripts e IDs proximos dos assets
- visual proprio estilo SF em vez de replica fiel do HTML/CSS do JS

---

## 4. Assets Presentes no Godot

### Personagens presentes em `assets/characters/`

- `samurai_mack` (8 animacoes, 100 HP, balanceado)
- `kenji` (8 animacoes, 100 HP, rapido)
- `evil_wizard` (8 animacoes, 90 HP, dano alto)
- `fantasy_warrior` (8 animacoes, 110 HP, tanque lento)
- `huntress` (8 animacoes, 85 HP, rapida e fragil)
- `huntress_2` (8 animacoes + projetil, 85 HP, range)
- `martial_hero` (8 animacoes, 100 HP, balanceado)
- `medieval_king` (8 animacoes, 120 HP, pesado e forte)

### Outros assets presentes

- `assets/audio/Perimore.mp3`
- `assets/stage/background.png`
- `assets/stage/shop.png`
- `assets/ui/Logo.jpg`

### Observacao sobre roster

O JS original tem 10 configs (inclui `evilWizard3` e `wizardPack`).
No Godot, apenas os 8 personagens cujos assets foram copiados estao
configurados em `DadosPersonagens.gd`.

---

## 5. Estrutura Atual do Projeto Godot

### Scripts principais

| Script | Funcao |
|---|---|
| `GameState.gd` | Autoload: estado global (modo, personagens, rounds, stats) |
| `CombatSystem.gd` | Autoload: hit processing, combo tracking, damage scaling |
| `AudioManager.gd` | Autoload: audio sintetizado procedural |
| `DadosPersonagens.gd` | Banco de dados de personagens (stats, sprites, hitboxes) |
| `Fighter.gd` | CharacterBody2D: maquina de estados, controle, animacao |
| `Projectile.gd` | Projetil com colisao e explosao |
| `BattleScene.gd` | Controlador da batalha (rounds, timer, ataques, efeitos) |
| `AIController.gd` | IA com 3 niveis (facil, medio, dificil) |
| `HUD.gd` | CanvasLayer: gerencia dados das barras e combo |
| `HUDDesenho.gd` | Custom draw: barras anguladas, timer, round dots |
| `MainMenu.gd` | Menu principal com navegacao |
| `MenuFundo.gd` | Fundo animado com faixas diagonais |
| `CharacterSelect.gd` | Selecao com teclado, previews, countdown |
| `PostMatch.gd` | Tela pos-partida com stats |
| `PauseMenu.gd` | Pausa com continuar/reiniciar/menu |
| `NumeroDano.gd` | Numeros de dano flutuantes |
| `CameraJogo.gd` | Camera shake baseado em trauma |
| `ComboDisplay.gd` | Display de combo ("X HITS") |
| `EfeitosVisuais.gd` | Particulas: sparks, poeira, aterrissagem |

### Cenas principais

- `scenes/MainMenu.tscn`
- `scenes/CharacterSelect.tscn`
- `scenes/Battle.tscn`
- `scenes/PostMatch.tscn`
- `scenes/Fighter.tscn`
- `scenes/Projectile.tscn`
- `scenes/ui/HUD.tscn`
- `scenes/ui/PauseMenu.tscn`
- `scenes/ui/NumeroDano.tscn`
- `scenes/ui/ComboDisplay.tscn`

---

## 6. Estado Real do Projeto JS

O projeto JS de referencia ja implementa:

- menu principal overlay
- selecao de personagem em dois paineis
- modos `versus`, `arcade` e `training`
- batalha completa em canvas
- pausa
- tela de pos-partida
- HUD com barras de vida e round dots
- screen shake
- particulas
- damage numbers
- combo display
- projeteis
- audio programatico

Arquivos JS mais importantes para a migracao:

- `src/scenes/BattleScene.js`
- `src/scenes/CharacterSelectScene.js`
- `src/scenes/MainMenuScene.js`
- `src/scenes/PostMatchScene.js`
- `src/entities/Fighter.js`
- `src/entities/Projectile.js`
- `src/systems/CombatSystem.js`
- `src/ai/AIController.js`
- `src/css/menu.css`
- `src/css/battle.css`
- `index.html`

---

## 7. O Que Ainda Falta

Lista realista do que ainda falta migrar ou polir:

### Alta prioridade

- validar hitboxes e offsets personagem por personagem (testar cada um)
- revisar alcance e frame windows de ataques para paridade com JS
- validar projeteis e timings do `huntress_2`
- testar fluxo ponta a ponta sem ajustes manuais

### Media prioridade

- fontes customizadas para fighting game (fonte bold/pixel art para titulos)
- camera tracking dos lutadores (zoom/pan leve baseado na distancia)
- melhorar IA do arcade (padroes mais variados, reacao a combos)
- portar os 2 personagens faltantes do JS (`evilWizard3`, `wizardPack`)

### Baixa prioridade

- audio sintetizado mais proximo do JS (mais variedade de sons)
- trails visuais em ataques e dash
- particulas mais detalhadas (poeira do chao, impacto no cenario)

---

## 8. Sugestoes de Melhoria (Alem do JS Original)

Ideias que iriam alem do projeto JS original e poderiam elevar o jogo:

### Gameplay

- **mecanica de bloqueio/defesa**: adicionar block com reducao de dano e chip damage
- **ataques aereos**: attack1/attack2 diferentes quando no ar
- **super meter**: barra que carrega com hits dados/recebidos e permite um super ataque
- **wall bounce**: knockback contra a parede do cenario causa bounce e combo extendido
- **juggle system**: hits aereos mantem o oponente no ar para combos mais elaborados

### Visual

- **tela de VS antes da luta**: transicao dramatica mostrando os dois personagens
- **efeito de KO**: slowmotion + zoom no ultimo hit que mata
- **vitoria animada**: personagem vencedor faz pose de vitoria
- **cenarios alternativos**: mais backgrounds com parallax scrolling
- **paleta de cores alternativa**: skins/cores diferentes para cada personagem

### Audio

- **anunciador de voz**: "Round 1", "Fight!", "K.O.", "Perfect" (pode ser sintetizado)
- **musicas por cenario**: trilhas diferentes para variar
- **efeitos de impacto mais ricos**: sons distintos para ataques leves vs pesados

### UX

- **tutorial interativo**: sequencia ensinando os controles e mecanicas
- **command list**: tela mostrando todos os golpes de cada personagem
- **replays**: gravar e reproduzir partidas
- **configuracao de controles**: permitir remapear teclas
- **suporte a gamepad**: controle por joystick/gamepad

### Tecnico

- **netcode para multiplayer online**: rollback netcode para partidas online
- **sistema de save**: salvar preferencias, estatisticas acumuladas, recordes
- **localizacao**: suporte a PT-BR e EN nas interfaces

---

## 9. Proximo Passo Recomendado

1. abrir o projeto no Godot 4.6.1
2. testar `MainMenu -> CharacterSelect -> Battle -> PostMatch`
3. validar visual das telas com o novo tema SF
4. testar combate de cada personagem (hitboxes, offsets, animacoes)
5. testar `arcade`, `treino` e `huntress_2`
6. registrar bugs ou gaps encontrados

---

## 10. Como Manter Este Arquivo Atualizado

Atualizar este arquivo sempre que:

- uma mecanica relevante for portada
- uma tela mudar bastante
- um asset importante for copiado
- uma divergencia relevante do JS for descoberta
- uma decisao de design/escopo for tomada

### Regra de manutencao

Este arquivo deve sempre responder:

- o que ja existe de verdade
- o que ainda nao existe
- o que esta funcional
- o que esta parcial
- o que ainda esta distante do JS

---

## 11. Resumo Executivo

Estado real hoje:

- o projeto Godot ja roda e esta jogavel com visual estilo Street Fighter
- todas as telas (menu, selecao, batalha, pausa, pos-partida) estao funcionais
- combate completo: ataques, combos, dash, projetil, rounds, timer
- 8 personagens jogaveis com stats e animacoes distintas
- 3 modos de jogo: versus, arcade (IA) e treino
- feedback visual completo: hit flash, particles, combo display, camera shake
- HUD com barras anguladas custom-drawn e tema vermelho/dourado
- o maior gap agora e refinamento fino: hitboxes por personagem, fontes customizadas, IA mais inteligente e features opcionais como bloqueio e super meter
