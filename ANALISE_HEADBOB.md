# Outlast - como o Head Bob funciona e como remove-lo

Este documento resume a analise feita com os arquivos deste repositorio
(`OLGame.upk`, `Engine.upk`, `Core.upk`, `*.ini` e os scripts decompilados em
`uc/`). A conclusao principal: **o head bob do Outlast nao e uma opcao de
configuracao**; ele esta gravado nos keyframes da bone `Hero-Camera` das
animacoes do protagonista.

---

## 1. O caminho da camera no jogo

1. `OLPlayerController.GetPlayerViewPoint()` (`uc/OLPlayerController.uc`,
   linhas 627-674) chama `HeroPawn.GetCamera(POVLocation, POVRotation, FOVAngle)`
   quando a visao e em primeira pessoa (linha 659).
2. `OLHero.GetCamera()` e uma funcao **nativa** (`uc/OLHero.uc`, linha 1142),
   ou seja, implementada em C++ dentro do executavel.
3. `OLHeroCamera` (`uc/OLHeroCamera.uc`) e a classe que mantem a visao. Ela tem
   `var config name CameraBoneName` (linha 152), cujo default e
   `CameraBoneName="Hero-Camera"` (linha 165). O `OLGame.ini` repete isso em
   `[OLGame.OLHeroCamera]` (linhas 332-335).
4. O codigo nativo atualiza a camera lendo **diretamente a transformacao da
   bone** `Hero-Camera` no SkeletalMesh a cada frame. A engenharia reversa
   publica do cliente OpenOL mostra exatamente isso:
   `UOLHeroCamera::GetAnimatedView()` faz
   `Hero->Mesh->GetBoneLocation(CameraBoneName)` e
   `Hero->Mesh->GetBoneQuaternion(CameraBoneName)`.
   O proprio mod de VR do Outlast documenta: *"the game camera is BONE-DRIVEN
   (OLGame.ini [OLGame.OLHeroCamera] CameraBoneName=Hero-Camera). Whatever
   GetViewPoint returns already contains the animated bob/sway/climb motion"*.

Ou seja: a camera nao recebe um offset procedural de caminhada. Ela **segue a
bone**, e a bone e animada. O balanco e arte/curadoria de animacao.

---

## 2. Onde o balanco esta gravado

No `OLGame.upk` existe o AnimSet **`03_Hero.Hero-01_AS`** (pacote seekfree; o
path virtual `03_Hero` e um export `Package` dentro do proprio OLGame.upk).

- `TrackBoneNames` tem 73 bones; `Hero-Camera` e o indice **70**.
- `UseTranslationBoneNames` contem apenas `Hero-Camera` e `Hero-L-UpperArm`:
  sao as unicas bones com track de translacao no heroi.
- O AnimSet tem 360 `AnimSequence` (`player_walk_forward`,
  `player_run_forward`, `player_stand_idle`, `player_stand_breathe_idle`,
  `player_crouch_forward`, etc.).
- Cada sequencia usa compressao per-track do UE3:
  `CompressedTrackOffsets` com 4 inteiros por bone:
  `transOffset, transKeys, rotOffset, rotKeys`.
- Cada key de translacao/rotacao tem **12 bytes** (3 floats; na rotacao o W e
  reconstruido). Quando `keys > 1`, depois das keys vem um array de tempos do
tamanho `keys`, alinhado a 4 bytes.

Medicoes feitas no pacote PC:

| Animacao | Translacao da camera (unreal units) | Rotacao (desvio max.) |
|---|---|---|
| `player_walk_forward` | X -1.55..1.55, Y 20.0..21.1, Z 167.80..169.04 (~1.25 uu de bob vertical) | 0.84 graus |
| `player_run_forward` | Z 156.58..158.22 (~1.65 uu) | 2.77 graus |
| `player_stand_idle` | Y 20.51..21.07, Z 168.19..168.54 (~0.35 uu) | 0.64 graus |
| `player_stand_breathe_idle` | respiracao | 5.45 graus |

A 100 uu/metro (escala medida do jogo), 1 uu = 1 cm. O bob vertical da
caminhada e ~1,2 cm; o da corrida ~1,6 cm. O idle mexe pouco em posicao, mas a
rotacao da respiracao chega a ~5 graus no `player_stand_breathe_idle`.

Alem disso, existem componentes procedurais menores:

- **Shake de impacto**: `ShakeData` / `SmallLandingShakeData` em
  `OLHeroCamera.uc` (linhas 149-159), disparados no pouso
  (`OLHero.PlayLanded`, linhas 1420-1426). Nao e o bob de caminhada.
- **Neck offset** por modo de locomocao (`LocomotionModeParams[].NeckOffsetFwd/
  NeckOffsetSide`, linhas 1926-1941), usado em pushing/ledge/etc.
- **Look back / lean** procedurais, tambem no camera code.

---

## 3. Por que nao existe um toggle no .ini

Buscamos em todos os arquivos de configuracao e no upk por `bob`, `headbob`,
`breath`, `sway`, `smooth`, etc. Nao existe nenhuma propriedade desse tipo.
`OLGame.ini` so expoe para `OLHeroCamera`:

```ini
[OLGame.OLHeroCamera]
CameraBoneName=Hero-Camera
ViewLimitsSoftZone=20.0
SoftZoneStiffness=1000.0
```

`CameraBoneName` e apenas o nome da bone; trocar por outra bone mudaria a
posicao da camera (e uma bone inexistente faria o UE3 retornar zero), nao e uma
solucao. `ShakeData` e `SmallLandingShakeData` nao sao `config`, entao tambem
nao podem ser alterados por ini.

---

## 4. Como remover

### Opcao A - editar os keyframes (foi o que o patcher faz)

Achatar (deixar constantes) os keyframes de translacao e rotacao da bone
`Hero-Camera` nas animacoes desejadas:

- translacao -> media dos keyframes (mantem a altura/posicao base da camera);
- rotacao -> quaternion medio normalizado (mantem a orientacao base).

Nao muda tamanhos, offsets nem os tempos das keys; so os valores de 3 floats de
cada key. E um patch seguro e reversivel, e nao depende do executavel.

O patcher em `patcher/` implementa isso com GUI, backup e restauracao.

### Opcao B - hook nativo (DLL/ASI)

Hookar `UOLHeroCamera::GetAnimatedView` (ou `AOLHero::GetCamera`) e ignorar a
transformacao animada da bone, mantendo apenas a posicao/rotacao do pawn. E o
que o cliente OpenOL faz com a opcao `SmoothCamera` (`bSmoothCamera` /
comando `ToggleSmoothCamera`), que zera pitch/roll da bone em walk/fall. E mais
invasivo, depende da versao do executavel e nao funciona no jogo vanilla sem
um injetor (o mod de VR usa um proxy `d3d9.dll` com MinHook).

### Opcao C - editar o AnimSet em um editor UE3

Exportar/importar o AnimSet `Hero-01_AS` no UDK 2015 (ou editar via UELib/UE
Explorer), zerar as tracks da camera e recozinhar o pacote. E o fluxo "de
autor", mais trabalhoso que o patch binario direto.

---

## 5. O que o patcher altera

- AnimSet: `03_Hero.Hero-01_AS` dentro de `OLGame.upk`.
- Bone: `Hero-Camera` (indice 70 em `TrackBoneNames`).
- Tracks: translacao e rotacao da camera nas sequencias selecionadas.
- Modos: caminhada+corrida padrao, todas as walk/run, somente walk, somente
  run, todas as animacoes.
- Checkbox separado para idle/respiracao.
- 5 animacoes de fatality usam um layout de track diferente e sao ignoradas
  (relatadas como `skipped_layout`).

Validacao feita no pacote real: 360 sequencias encontradas, 355 com layout
padrao; nos modos testados, todas as sequencias selecionadas ficaram com
desvio zero e nenhuma sequencia nao selecionada foi alterada (comparacao byte a
byte).
