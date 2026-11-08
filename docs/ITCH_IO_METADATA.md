# Guia de Publicação no Itch.io — Antes do Amanhecer (M5 Lançamento)

Este documento contém todas as informações, metadados e diretrizes necessárias para a publicação e distribuição da versão pública (**M5 Lançamento**) de **Antes do Amanhecer** no [itch.io](https://itch.io).

---

## 1. Metadados do Projeto

* **Título do Jogo**: *Antes do Amanhecer*
* **Título Curto / URL Slug**: `antes-do-amanhecer`
* **Gênero**: Roguelite, Horda, Ação Sobrevivência (Survivors-like), 2D Top-Down
* **Estilo Visual**: Pixel Art Sertanejo Gótico / Caricato (640x360 escalonado)
* **Temática / Ambientação**: Folclore Brasileiro e Sertão Mítico
* **Classificação Indicativa**: 12+ (Violência fantasiosa e monstros folclóricos)
* **Idiomas**: Português Brasileiro (PT-BR) nativo
* **Preço Sugerido**: Gratuito / Pague o quanto quiser (*Free / Name your own price*)

---

## 2. Descrições Promocionais

### Frase de Efeito (Tagline)
> *"Noite adentro no sertão amaldiçoado: empunhe a reza, a pólvora e o facão. Sobreviva até os primeiros raios de sol romperem o pacto."*

### Descrição Curta (Short Description)
> *Antes do Amanhecer* é um survivors-like ágil ambientado no folclore brasileiro. Enfrente até 2.000 criaturas sobrenaturais simultâneas em partidas intensas de 20 minutos, desbloqueie armas e evoluções místicas, aprimore seu Candeeiro e sobreviva até o alvorecer!

### Descrição Completa (Markdown para Itch.io)
```markdown
# Sobre o Jogo
Em **Antes do Amanhecer**, o sertão caiu sob uma noite perpétua regida por um pacto sinistro. Escolha entre 6 Vigilantes lendários da nossa cultura popular e resista a hordas crescentes de criaturas do folclore como o Boitatá, a Mula-sem-cabeça, o Saci e o colossal Mapinguari.

### Destaques
- **Ação Desenfreada**: Tecnologia de grade espacial suportando mais de 2.000 entidades ativas a 60 FPS contínuos.
- **6 Classes com Poderes Únicos**: Jogue com a Benzedeira, o Cangaceiro, o Ferreiro, o Capoeirista, o Violeiro ou o Coveiro.
- **Arsenal Folclórico e Fusões Secretas**: Combine o *Galho de Arruda*, a *Garrucha*, o *Fogo-Fátuo*, o *Facão* e o *Sino da Capela*. Evolua para a *Coroa de Arruda*, o *Trovão do Sertão* e libere a mítica *Aurora Rubra*!
- **Progressão Roguelite**: Colete moedas de ouro nas partidas e invista permanentemente n'**O Candeeiro** com 100% de reembolso livre a qualquer momento.
- **O Grimório Vivo**: Descubra criaturas, relíquias e receitas místicas para preencher sua enciclopédia folclórica.
- **Acessibilidade Completa**: Sliders de tremor de tela, hit-stop personalizável, modo de fotossensibilidade e números de dano opcionais.

### Controles
- **Movimentação**: WASD ou Setas Direcionais (suporte nativo a Gamepad/Analógico).
- **Ataque**: Automático conforme alcance e recarga.
- **Especial (Fúria da Noite)**: Tecla Espaço ou Botão Sul do Controle.
- **Pausa / Menu**: Tecla ESC ou Botão Start.
```

---

## 3. Presets de Exportação e Instruções de Build

O arquivo [`export_presets.cfg`](file:///c:/Projetos/AntesDoAmanhecer/export_presets.cfg) já está configurado para:

1. **Windows (64-bit Desktop)**:
   - Caminho de saída: `builds/windows/AntesDoAmanhecer.exe`
   - Compactar como arquivo `.zip` para upload no Itch.io.
   
2. **Linux (x86_64 Desktop)**:
   - Caminho de saída: `builds/linux/AntesDoAmanhecer.x86_64`
   - Adicionar permissão de execução `chmod +x AntesDoAmanhecer.x86_64` e empacotar em `.tar.gz` ou `.zip`.

3. **Web (HTML5 / WebAssembly / Navegador)**:
   - Caminho de saída: `builds/web/index.html`
   - Compactar os arquivos gerados (`index.html`, `index.js`, `index.pck`, `index.wasm`) diretamente na raiz de um arquivo `antes-do-amanhecer-web.zip`.
   - No Itch.io, marcar a opção **"This file will be played in the browser"** com viewport **1280x720** (escala inteira 2x de 640x360).

---

## 4. Tags Recomendadas para Visibilidade
`roguelite`, `survivors-like`, `folklore`, `brazilian-folklore`, `pixel-art`, `retro`, `2d`, `horde-survival`, `action-roguelike`, `indie`, `godot`.
