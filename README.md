# Antes do Amanhecer 🌅🕯️

[![Godot Engine](https://img.shields.io/badge/Godot-4.3_GL__Compatibility-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org)
[![Platform](https://img.shields.io/badge/Plataformas-Windows%20%7C%20Linux%20%7C%20Web%20(HTML5)-brightgreen)](#)
[![Tests](https://img.shields.io/badge/Testes_Unitários-14_Suítes_100%25_PASS-success)](#)
[![Target FPS](https://img.shields.io/badge/Desempenho-60_FPS_com_2.000+_Inimigos-orange)](#)
[![Genre](https://img.shields.io/badge/Gênero-Roguelite_Horde_Survival-blueviolet)](#)

> *"Noite adentro no sertão amaldiçoado: empunhe a reza, a pólvora e o facão. Sobreviva 20 minutos até os primeiros raios de sol romperem o pacto da Noite Perpétua."*

**Antes do Amanhecer** é um roguelite de ação e sobrevivência em hordas (*survivors-like*) em visão superior 2D, fortemente inspirado no rico imaginário do folclore e da cultura popular brasileira. Desenvolvido em **Godot 4.3** com GDScript estaticamente tipado e focado em altíssimo desempenho.

---

## 📖 Sinopse e Ambientação

Em um sertão mítico do início do século XX, o temido **Coronel Aurélio** selou um pacto sombrio com a **Lua Negra**, aprisionando a donzela Aurora e mergulhando os vilarejos em uma noite eterna habitada por assombrações, sacis, mulas-sem-cabeça e feras ancestrais.

Sua única esperança é a chama da **Candeia Viva**. Como um dos seis Vigilantes lendários da caatinga, você deve resistir a hordas crescentes de criaturas sobrenaturais das **20:00 às 00:00 (20 minutos)** para libertar o dia!

---

## ⚔️ Os 6 Vigilantes Lendários

| Vigilante | Arquétipo | Arma Inicial | Poder Especial (Fúria da Noite) | Habilidade Passiva |
| :--- | :--- | :--- | :--- | :--- |
| **Benzedeira** | Suporte & Área | *Galho de Arruda* | **Reza Forte**: 5s de invulnerabilidade e onda sagrada repulsora | Regenera 1 PV a cada 5s e +10% de área |
| **Cangaceiro** | Crítico & Agilidade | *Garrucha* | **Chuva de Chumbo**: Disparos perfurantes em leque contínuo | +15% de velocidade e +10% de chance crítica |
| **Capoeirista** | Mobilidade & Evasão | *Facão* | **Roda da Morte**: Esquiva ágil em 360° com rasteiras | +20% de esquiva e +15% de velocidade |
| **Ferreiro** | Tanque & Armadura | *Facão* | **Fogo de Forja**: Impacto sismico incandescente | +40 PV máximo e 15% de redução de dano |
| **Violeiro** | Controle & Debuff | *Sino da Capela* | **Toque da Alvorada**: Desacelera a horda em 60% | +25% de raio de coleta e +15% de duração |
| **Coveiro** | Necromancia & Dano | *Fogo-Fátuo* | **Cova Aberta**: Puxa inimigos para um vórtice espectral | +20 PV e ganha +1% de dano por cada 50 abates |

---

## 🔮 Arsenal Folclórico & Fusões Secretas

Colete gemas de XP para subir de nível e abrir baús de tesouro com a arma no nível 5 e a passiva correspondente para liberar **Evoluções Míticas**:

* 🌿 **Galho de Arruda** + **Escapulário** $\rightarrow$ **Coroa de Arruda** (dois anéis orbitais e cura sagrada contínua).
* 🔫 **Garrucha** + **Ferradura** $\rightarrow$ **Trovão do Sertão** (tiros duplos em leque de penetração infinita).
* 🔥 **Fogo-Fátuo** + **Chapéu de Couro** $\rightarrow$ **Boitatá** (serpente colossal de fogo teleguiada).
* 🔪 **Facão** + **Ferradura** $\rightarrow$ **Facão Furioso** (giro devastador em 360 graus).
* 🔔 **Sino da Capela** + **Garrafada** $\rightarrow$ **Repique Final** (ondas sonoras congelantes em área contínua).
* ☀️ **Fusão Mítica Secreta**: Combine o **Boitatá** e o **Sol Pequeno** para forjar a lendária **Aurora Rubra**, banindo a escuridão do mapa!

---

## 🏛️ Trilogia de Atos & Bestiário

1. **Ato 1: Vila de Candeia** ([`scenes/partida/partida_teste.tscn`](file:///c:/Projetos/AntesDoAmanhecer/scenes/partida/partida_teste.tscn)):
   - Casario colonial, praça de barro e igreja.
   - Chefes: **Mapinguari** (minuto 10) e a **Cuca** (minuto 18).
2. **Ato 2: Canavial Amaldiçoado** ([`scenes/estagios/canavial_amaldicoado.tscn`](file:///c:/Projetos/AntesDoAmanhecer/scenes/estagios/canavial_amaldicoado.tscn)):
   - Trilhos abandonados e a velha moenda mal-assombrada.
   - Chefes: **Boitatá Colossal** (minuto 12) e a **Mula Gigante** (minuto 19).
3. **Ato 3: Capela do Pacto** ([`scenes/estagios/capela_pacto.tscn`](file:///c:/Projetos/AntesDoAmanhecer/scenes/estagios/capela_pacto.tscn)):
   - Cripta de pedra ardósia e o engenho ardendo em chamas carmesim.
   - Chefes: **Coronel Aurélio** (minuto 15) e a **Lua Negra** (minuto 20).
4. **Modo Bônus: Noite Infinita** ([`scenes/estagios/noite_infinita.tscn`](file:///c:/Projetos/AntesDoAmanhecer/scenes/estagios/noite_infinita.tscn)):
   - Sobrevivência sem relógio com marcos de abate e a aparição da temida entidade **A Hora Morta**.

---

## ⚙️ Arquitetura de Alto Desempenho

O jogo foi projetado para sustentar **60 FPS estáveis mesmo com mais de 2.000 monstros na tela**:

* **Grade Espacial (`SpatialHashGrid`)**: Chave binária compacta de 32-bit `(x & 0xFFFF) | ((y & 0xFFFF) << 16)` executada em memória contígua sem alocações de string.
* **Renderização em Lote (`EnemySwarmManager`)**: Única `MultiMeshInstance2D` gerencia todo o enxame via `PackedVector2Array` e `PackedFloat32Array`.
* **Sintetizador de Áudio Procedural (`AudioManager`)**: Sintetiza nativamente ondas PCM em 16-bit com modulação de tom (pitch shift 0.94 a 1.06) sem depender de arquivos pesados.
* **Salvamento Atômico Seguro (`SaveSystem`)**: Grava em arquivo `.tmp` e executa troca atômica no disco para prevenir corrupção de save (**RNF-08**, **CA-16**).

---

## 🎮 Controles

| Ação | Teclado | Gamepad / Controle |
| :--- | :--- | :--- |
| **Mover Vigilante** | `W`, `A`, `S`, `D` ou Setas | Analógico Esquerdo / D-Pad |
| **Ataque** | Automático | Automático |
| **Especial (Fúria da Noite)** | Barra de `Espaço` | Botão Sul (`A` no Xbox / `X` no PS) |
| **Pausar / Menu** | Tecla `ESC` | Botão `Start` / Menu |

---

## 🧪 Testes Automatizados (14 Suítes)

Para validar a integridade de todas as mecânicas sem necessidade de teste manual:

```bash
# Executa a suíte de testes no terminal headless do Godot
godot --headless -s tests/test_runner.gd
```

Ou abra [`tests/test_runner.tscn`](file:///c:/Projetos/AntesDoAmanhecer/tests/test_runner.tscn) no editor e aperte **F6**. Todas as 14 suítes cobrindo os 16 Critérios de Aceite (**CA-01 a CA-16**) são executadas em milissegundos com 100% de sucesso.

---

## 📦 Como Compilar e Exportar

Os presets oficiais de exportação estão definidos em [`export_presets.cfg`](file:///c:/Projetos/AntesDoAmanhecer/export_presets.cfg):

```bash
# Windows 64-bit
godot --headless --export-release "Windows Desktop" builds/windows/AntesDoAmanhecer.exe

# Linux x86_64
godot --headless --export-release "Linux/X11" builds/linux/AntesDoAmanhecer.x86_64

# Web / Itch.io (HTML5)
godot --headless --export-release "Web (Itch.io)" builds/web/index.html
```

Consulte o guia de publicação em [`docs/ITCH_IO_METADATA.md`](file:///c:/Projetos/AntesDoAmanhecer/docs/ITCH_IO_METADATA.md) para detalhes de distribuição no Itch.io.

---

## 📄 Licença

Desenvolvido com carinho celebrando as lendas e a literatura de cordel brasileira. Distribuído sob a licença MIT.
