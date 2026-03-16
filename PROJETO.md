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

Hoje o projeto Godot ja tem uma base funcional jogavel.

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
- batalha
- pausa
- pos-partida

### Features atualmente implementadas no Godot

- menu com layout em duas colunas inspirado no JS
- navegacao por teclado no menu principal
- movimentacao lateral
- pulo e gravidade
- dash por double-tap
- `attack1`
- `attack2`
- hit detection por retangulos
- dano e knockback
- hitstun
- invulnerabilidade curta
- combo scaling simples
- rounds
- timer
- versus
- arcade com IA simples
- treino com dummy
- selecao com previews, confirmacao por teclado e countdown
- projetil para `huntress_2`
- HUD em layout aproximado do canvas original
- numeros de dano
- camera shake simples
- musica de batalha
- estatisticas basicas de partida
- pausa com continuar/reiniciar/menu
- pos-partida com stats e navegacao por teclado
- hitboxes visiveis no treino com `H`
- combo display dedicado por jogador
- particulas de hit (sparks com cor escalando por combo)
- poeira de aterrissagem e dash
- flash branco ao receber dano (shader)
- hit freeze frame curto para feedback de impacto
- sequencia READY / FIGHT! no inicio de cada round
- numeros de dano com escala e animacao baseada em combo

### O que ainda esta incompleto ou distante do JS

- design das telas ja foi aproximado estruturalmente, mas ainda nao e uma replica fiel do HTML/CSS do JS
- HUD ainda nao tem o mesmo acabamento e animacao visual do original
- selecao ja tem confirmacao e countdown, mas ainda nao replica o fluxo/cartoes do JS com a mesma fidelidade
- menu ja tem navegacao por teclado, mas ainda nao tem todos os overlays/modais do original
- pos-partida e pausa ja existem com navegacao, mas ainda faltam acabamento e polish
- efeitos visuais do JS ainda podem ser mais refinados (particulas mais detalhadas, trails)
- audio sintetizado do JS ainda nao foi aproximado com fidelidade
- falta validar personagem por personagem

### Decisoes atuais

- nao existe mecanica de bloqueio no Godot
- o alinhamento de sprite hoje usa bounding box visivel do `idle`
- nomes internos seguem PT-BR nos scripts e IDs proximos dos assets

---

## 4. Assets Presentes no Godot

### Personagens presentes em `assets/characters/`

- `samurai_mack`
- `kenji`
- `evil_wizard`
- `fantasy_warrior`
- `huntress`
- `huntress_2`
- `martial_hero`
- `medieval_king`

### Outros assets presentes

- `assets/audio/Perimore.mp3`
- `assets/stage/background.png`
- `assets/stage/shop.png`
- `assets/ui/Logo.jpg`

### Observacao sobre roster

O roster/config atual do JS e maior do que o roster realmente migrado.

No indice do JS existem 10 configs:

- `samuraiMack`
- `kenji`
- `evilWizard`
- `fantasyWarrior`
- `huntress`
- `martialHero`
- `medievalKing`
- `evilWizard3`
- `huntress2`
- `wizardPack`

No Godot, o conjunto funcional atual cobre os personagens cujos assets ja
estao copiados e configurados em `DadosPersonagens.gd`.

---

## 5. Estrutura Atual do Projeto Godot

### Scripts principais

- `scripts/GameState.gd`
- `scripts/CombatSystem.gd`
- `scripts/AudioManager.gd`
- `scripts/DadosPersonagens.gd`
- `scripts/Fighter.gd`
- `scripts/Projectile.gd`
- `scripts/BattleScene.gd`
- `scripts/AIController.gd`
- `scripts/HUD.gd`
- `scripts/MainMenu.gd`
- `scripts/CharacterSelect.gd`
- `scripts/PostMatch.gd`
- `scripts/PauseMenu.gd`
- `scripts/NumeroDano.gd`
- `scripts/CameraJogo.gd`
- `scripts/ComboDisplay.gd`
- `scripts/EfeitosVisuais.gd`

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

## 7. Divergencias Conhecidas Entre JS e Godot

### Visual

- o JS usa overlays HTML/CSS com identidade retro/neon mais forte
- o Godot ja esta numa aproximacao visual parcial, mas ainda nao numa replica fiel

### UX

- o JS usa navegacao por teclado nos menus
- o Godot ja tem navegacao por teclado em menu, pausa, pos-partida e parte da selecao
- ainda faltam mais consistencia visual de foco e mais fidelidade de fluxo na selecao

### Combate

- o JS referencia mecanicas de bloqueio em alguns pontos
- no Godot isso foi removido por decisao do projeto

### Efeitos

- o JS tem mais polish visual
- o Godot atual esta funcional, mas simplificado

### Personagens

- o JS ainda tem inconsistencias historicas entre documentacao e codigo
- o Godot deve continuar usando o codigo JS como referencia principal, nao a documentacao antiga

---

## 8. O Que Falta Para Aproximar de "100%"

Lista realista do que ainda falta migrar ou polir:

- refinar o design de `MainMenu`, `CharacterSelect`, `HUD` e `PostMatch`
- reproduzir melhor o acabamento/foco visual dos menus do JS
- aproximar mais os cartoes e o fluxo da selecao do original
- revisar hitboxes e offsets personagem por personagem
- revisar alcance e frame windows de ataques
- portar ou aproximar:
  - particulas mais detalhadas e trails
  - mais polish de camera (tracking dos lutadores)
- melhorar IA para ficar mais proxima do JS
- validar projeteis e timings por personagem
- revisar a tela de pausa
- validar todo o fluxo ponta a ponta sem ajustes manuais

---

## 9. Proximo Passo Mais Seguro

O proximo passo tecnico recomendado e:

1. abrir o projeto no Godot 4.6.1
2. testar `MainMenu -> CharacterSelect -> Battle -> PostMatch`
3. validar visual das telas apos os ultimos ajustes
4. testar combate de `samurai_mack` vs `kenji`
5. testar `arcade`, `treino` e `huntress_2`
6. registrar o proximo gap real encontrado

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

- o projeto Godot ja roda e esta jogavel
- menu, selecao, batalha, pausa e pos-partida existem
- as telas principais ja receberam uma primeira aproximacao visual do JS
- menu, pausa e pos-partida ja aceitam navegacao por teclado
- a selecao ja tem confirmacao por teclado e countdown
- combate base, rounds, treino, arcade e projetil ja existem
- o maior gap agora nao e mais parser ou estrutura basica
- o maior gap agora e paridade visual, polish e comportamento fino frente ao JS
