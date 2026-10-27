# Outlast — análise técnica do HeadBob

## Resumo

O HeadBob de *Outlast* **não é um efeito procedural** e **não tem uma opção de
configuração**. Ele é o movimento da própria câmera em primeira pessoa, que está
presa ao osso `Hero-Camera` do esqueleto do Miles. As animações de caminhada e
corrida (`player_walk_*`, `player_run_*`) possuem uma trilha de **translação**
explícita para esse osso. É essa trilha que sobe/desce, balança lateralmente e
inclina a câmera. Em outras palavras: o HeadBob está *assado* (baked) dentro das
animações.

Isso foi confirmado dentro do próprio `OLGame.upk`:

* `OLHeroCamera.CameraBoneName = Hero-Camera` (o osso usado pela câmera).
* `AnimSet Hero-01_AS` declara `UseTranslationBoneNames = [Hero-Camera,
  Hero-L-UpperArm]`. A câmera é **um dos apenas dois ossos** cuja translação é
  animada — exatamente o ingrediente do HeadBob.
* Em `player_walk_forward` a trilha da câmera oscila em Z entre **167,80 cm e
  169,04 cm** (`ΔZ = 1,25 cm`), além de `ΔX = 3,10 cm` e `ΔY = 1,10 cm`.
* Em `player_run_forward` a oscilação é `ΔZ = 1,64 cm`, `ΔX = 2,08 cm`, com
  rotação variando até **2,77°**.
* Não existe nenhuma variável, config ou nó de AnimTree chamado `bob`, e o
  `Player_AnimTree` não possui um nó gerador de HeadBob. Os únicos nós de câmera
  (`OLAnimCameraSpace`) tratam dos braços (`LeftArmCamSpace`, `RightArmCamSpace`,
  `UpperBodyCamSpace`), não da cabeça.

**Conclusão:** é possível remover o HeadBob. A forma mais segura e cirúrgica é
achatar (ou suavizar) a trilha de translação/rotação do osso `Hero-Camera`
somente nas animações desejadas. O pacote de animação está dentro do
`OLGame.upk`, então a correção pode ser feita sem tocar no executável do jogo.

## 1. Arquivos analisados

| Arquivo | Papel |
|---|---|
| `OLGame.upk` | pacote UE3 comprimido (LZO), 64,7 MB |
| `upk/unpacked/OLGame.upk` | mesmo pacote descomprimido, 85,6 MB, com a flag de compressão removida |
| `uc/OLHero.uc` | classe nativa do Miles; declara `HeadBoneName`, `AnimSets`, `Camera`, FOV, modos de locomoção |
| `uc/OLHeroCamera.uc` | classe nativa da câmera; declara `CameraBoneName`, `ShakeData`, limites de visão |
| `uc/OLPlayerController.uc` | controlador; câmera, zoom da camcorder, `bBehindView` |
| `OLGame.ini` / `DefaultGame.ini` | configs; contêm apenas `CameraBoneName=Hero-Camera`, FOV e velocidades |
| `OLEngine.ini` / `OLInput.ini` | engine/input; nada relacionado a HeadBob |
| `tools/outlast_upk.py` | leitor UE3 usado na análise |
| `tools/headbob_patch.py` | patcher que remove o HeadBob |

O pacote usa **UE3 versão 868 / licensee 3**. O arquivo em `upk/unpacked/` tem a
flag `PKG_Compressed` limpa (`0x60A80009` em vez de `0x62A80009`), portanto pode
ser lido/editado como um pacote normal.

## 2. Como a câmera do Outlast funciona

`OLHeroCamera` é uma classe nativa. A parte relevante em `uc/OLHeroCamera.uc`:

```unrealscript
var OLHero Hero;
var CamView ViewWS;          // view em world space
var CamView ViewCS;          // view em camera space
var Rotator BaseRotation;
var Vector BaseLocation;
var float NeckOffsetFwd;
var float NeckOffsetSide;
var CameraShakeData ShakeData;
var const CameraShakeData SmallLandingShakeData;
var config name CameraBoneName;   // "Hero-Camera"
```

O fluxo é:

1. `OLHero.GetCamera(...)` (nativo) pede a posição/rotação para `OLHeroCamera`.
2. `OLHeroCamera` pega o transform do osso `CameraBoneName` no
   `SkeletalMeshComponent` do Miles, aplica os offsets de pescoço/limites de
   visão e devolve a câmera.
3. O jogador controla yaw/pitch; o resultado final é a soma disso com o
   transform animado do osso.

Como a câmera é *filha* do esqueleto, **tudo o que a animação faz com o osso
`Hero-Camera` aparece na tela**. Não há separação entre “corpo animado” e
“câmera estável”.

No `uc/OLHero.uc`:

```unrealscript
AnimSets[0]=AnimSet'03_Hero.Hero-01_AS'
AnimSets[1]=AnimSet'03_OL_ScriptedEvents.Hero_SE'
AnimTreeTemplate=AnimTree'02_Behaviors.Player.Player_AnimTree'
HeadBoneName="Hero-Head"
```

No pacote, esses objetos existem de fato dentro do `OLGame.upk`:

* `Hero-01_AS` (AnimSet, 360 sequências) — todas as animações do jogador.
* `Hero_SE` (AnimSet, 21 sequências) — eventos scriptados.
* `Player_AnimTree` (AnimTree, ~200 nós).

Na hierarquia do SkeletalMesh `Miles_beheaded` (export 13880), o osso
`Hero-Camera` tem **parent index 0**, ou seja, é filho direto de `Hero-Root`.
Ele não está pendurado em `Hero-Head`/`Hero-Neck`. Isso é importante: a
translação da câmera é relativa ao root e **não herda** o movimento de pelve,
coluna, pescoço ou cabeça. Portanto, achatar a trilha da câmera remove o bob por
completo, sem precisar mexer no corpo.


## 3. A prova: o AnimSet manda animar a translação da câmera

O objeto `Hero-01_AS` contém as propriedades:

```text
bAnimRotationOnly        = False
TrackBoneNames           = [Hero-Root, Hero, Hero-Pelvis, ..., Hero-Camera,
                            Hero-L-Hand_aux, Hero-R-Hand_aux]   (73 ossos)
UseTranslationBoneNames  = [Hero-Camera, Hero-L-UpperArm]
Sequences                = 360 referências a AnimSequence
```

`bAnimRotationOnly=False` significa: **use a translação de todos os ossos**. O
array `UseTranslationBoneNames` existe justamente para o caso
`bAnimRotationOnly=True`; os desenvolvedores deixaram a lista preenchida mesmo
com o flag desligado, o que mostra a intenção de animar a câmera.

O osso `Hero-Camera` é o índice **70** da lista de tracks. Em cada AnimSequence,
`CompressedTrackOffsets` tem 4 inteiros por osso:

```text
[translation_offset, translation_key_count, rotation_offset, rotation_key_count]
```

Para `player_walk_forward` (export 9837):

```text
NumFrames              = 30
SequenceLength         = 0.966667 s
TranslationCompression = ACF_None  (0)  -> 3 floats (12 bytes) por chave
RotationCompression    = ACF_Float96NoW    -> 3 floats (12 bytes) por chave
camera trans offset    = 24928, 30 chaves
camera rot   offset    = 25320,  6 chaves
```

Primeiras chaves de translação da câmera (X, Y, Z em cm):

```text
(-1.10, 20.80, 168.25)
(-1.28, 20.94, 168.54)
(-1.41, 21.04, 168.77)
(-1.50, 21.09, 168.93)
(-1.55, 21.10, 169.02)
(-1.55, 21.07, 169.04)
...
```

Isso é o HeadBob, literalmente. A altura da câmera fica em ~168 cm e oscila
1,25 cm; X oscila 3,10 cm; Y (frente) 1,10 cm. A rotação da câmera também varia
~0,84° (walk) a ~2,77° (run), o que adiciona o balanço/inclinação.

### Amplitudes medidas nas animações-base

| AnimSequence | chaves pos | chaves rot | ΔX (cm) | ΔY (cm) | ΔZ (cm) | Δrotação |
|---|---:|---:|---:|---:|---:|---:|
| `player_walk_forward` | 30 | 6 | 3,10 | 1,10 | 1,25 | 0,84° |
| `player_walk_backward` | 30 | 5 | 3,10 | 1,10 | 1,25 | 0,90° |
| `player_walk_strafe_left` | 31 | 6 | 1,10 | 3,10 | 1,25 | 0,84° |
| `player_walk_strafe_right` | 31 | 6 | 1,10 | 3,10 | 1,25 | 0,84° |
| `player_walk_forward_water` | 30 | 6 | 3,10 | 1,10 | 1,25 | 0,84° |
| `player_run_forward` | 26 | 11 | 2,08 | 0,00 | 1,64 | 2,77° |
| `player_run_backwards` | 26 | 11 | 2,08 | 0,00 | 1,64 | 2,68° |
| `player_run_left` | 25 | 10 | 1,92 | 0,00 | 1,64 | 2,77° |
| `player_run_right` | 26 | 11 | 2,08 | 0,00 | 1,64 | 2,77° |

As animações de `hobble` (mancando) e `hurt` (levando dano) têm amplitudes muito
maiores (por exemplo `player_walk_hobble_stumble`: ΔY=38 cm, ΔZ=26 cm), mas isso
é movimento intencional de tropeço/dano, não o bob cíclico.

## 4. O que NÃO é a causa

Para evitar patches errados, estas hipóteses foram descartadas:

* **`ShakeData` / `SmallLandingShakeData`** — são shakes de impacto de curta
  duração (0,4 s e 0,2 s), com ondas de 20–122 Hz. Servem para dano, queda e
  aterrissagem; não são acionados continuamente ao andar. Além disso, não há
  chamada de shake no script de locomoção.
* **AnimTree** — o `Player_AnimTree` tem ~200 nós. Os nós `OLAnimCameraSpace`
  (`LeftArmCamSpace`, `RightArmCamSpace`, `UpperBodyCamSpace`) fazem blend
  per-bone dos braços em camera space. Não existe nó de HeadBob nem controle de
  `Hero-Camera` no AnimTree.
* **FOV** — `DefaultFOV=90`, `RunningFOV=100`, `FOVApproachCoeffRun=0.4`
  alteram o zoom ao correr, mas não produzem oscilação vertical.
* **Configs** — não há `bBob`, `HeadBob`, `CameraBob`, `BobAmplitude` etc. em
  `OLGame.ini`, `DefaultGame.ini`, `OLEngine.ini` ou `OLInput.ini`. A única
  config de câmera é `CameraBoneName=Hero-Camera`.
* **Motion blur / grain** — efeitos de pós-processamento, sem relação com o
  movimento da câmera.


## 5. É possível remover só ao andar/correr? E totalmente?

Sim, para os dois casos, mas com escopos diferentes:

### 5.1 Só durante andar/correr (recomendado)

Editando apenas as sequências cíclicas de caminhada/corrida:

* `player_walk_forward`, `player_walk_backward`, `player_walk_strafe_left`,
  `player_walk_strafe_right` (+ variantes `_water`);
* `player_run_forward`, `player_run_backwards`, `player_run_left`,
  `player_run_right`.

São **12 sequências** no total. Para cada uma:

1. localiza-se o track do osso `Hero-Camera` (índice 70);
2. calcula-se a média das chaves de translação;
3. grava-se essa média em todas as chaves (mesma quantidade de chaves, mesmo
   tamanho em bytes);
4. opcionalmente faz-se o mesmo com a rotação (média dos quaternions).

O resultado é uma câmera estável durante o ciclo, mantendo a altura média
pretendida de cada animação. Como a altura média de `walk` (~168,4 cm) e de
`run` (~157,4 cm) é diferente, a transição andar→correr continua abaixando a
câmera como no jogo original — só a oscilação some.

### 5.2 Remover totalmente

Duas abordagens são possíveis:

**A. Editar todas as sequências do Hero (recomendado para “total”)**

O `OLGame.upk` contém 360 sequências em `Hero-01_AS` + 21 em `Hero_SE`. O script
`--mode all --rotation none` achata a translação da câmera em **339** dessas
sequências (as demais não têm track de câmera). Isso remove o bob em walk, run,
idle, crouch, água, quedas etc.

Cuidado: algumas sequências usam a câmera de propósito (cutscenes, abrir porta
correndo, sendo agarrado). Achatá-las congela a câmera nesses momentos. Para um
“total” mais conservador, use `--mode walk-run-all` (todas as animações cujo
nome começa com `player_walk`/`player_run`, incluindo hurt/hobble) ou informe um
`--match` próprio.

**B. Alterar o AnimSet (global, mas arriscado)**

Seria possível mudar `bAnimRotationOnly` de `False` para `True` e remover
`Hero-Camera` de `UseTranslationBoneNames`. Isso ignora a translação da câmera
em **todas** as animações de uma vez. Porém `bAnimRotationOnly=True` também
ignora a translação de todos os outros ossos (exceto root e os listados), o que
pode quebrar agachamento, quedas e animações que dependem de translação de
pelve. Por isso o patcher **não** usa essa abordagem; ele edita somente as
chaves da câmera.

### 5.3 O que não é removido

* Shake de dano/queda/aterrissagem (`ShakeData`) continua.
* Movimentos intencionais de câmera em cutscenes e ações scriptadas continuam
  (a menos que você use `--mode all`).
* Não é necessário mexer em FOV, motion blur ou grain.


## 6. A ferramenta

`tools/headbob_patch.py` implementa o patch em escala de bytes, sem reconstruir
o pacote. Ele valida o resultado relendo o arquivo gerado.

```bash
# 1) Listar as animações e as amplitudes (não escreve nada)
python3 tools/headbob_patch.py --list --mode walk-run

# 2) Patch recomendado: somente walk/run cíclico, translação + rotação
python3 tools/headbob_patch.py --mode walk-run
#    -> build/OLGame_headbob_fixed.upk
#    -> build/headbob_report.json

# 3) Todas as animações walk/run (inclui hurt/hobble/door)
python3 tools/headbob_patch.py --mode walk-run-all

# 4) Todas as animações do Hero (translação; rotação preservada)
python3 tools/headbob_patch.py --mode all --rotation none

# 5) Seleção própria
python3 tools/headbob_patch.py --match '^player_(walk|run|crouch)' \
    --translation flatten --rotation flatten

# 6) Só conferir sem gravar
python3 tools/headbob_patch.py --mode walk-run --dry-run
```

Opções úteis:

* `--translation flatten|none` — achata ou ignora a translação.
* `--translation-anchor mean|first` — usa a média ou a primeira chave como
  valor constante.
* `--rotation flatten|none` — achata ou ignora a rotação da câmera.
* `--animset Hero-01_AS,Hero_SE` — AnimSets alvo.
* `--bone Hero-Camera` — osso da câmera.

### Instalação do mod

1. Faça backup de `.../Outlast/CookedPCConsole/OLGame.upk` (o arquivo original
   tem ~64,7 MB e é comprimido).
2. Gere `build/OLGame_headbob_fixed.upk`.
3. Renomeie para `OLGame.upk` e substitua o arquivo no jogo.
4. Se o jogo não iniciar, restaure o backup. O pacote gerado é **não
   comprimido** (85,6 MB); o UE3 do Outlast aceita pacotes sem compressão, mas
   essa é a etapa que depende da versão/região do executável.



## 7. Resultado da validação local

O patch `--mode walk-run` foi executado sobre `upk/unpacked/OLGame.upk`:

```text
Patched 12 sequences: 345 translation keys, 90 rotation keys, 3736 bytes changed.
Written : build/OLGame_headbob_fixed.upk (85,630,236 bytes)
Validation: OK (camera tracks are stable; package size unchanged)
```

Os testes (`python3 -m unittest discover -s tests -v`) verificam:

* o pacote continua com o mesmo tamanho e o mesmo header;
* apenas bytes dentro dos tracks da câmera foram alterados;
* após o patch, a variância da translação e da rotação da câmera é zero nas 12
  sequências;
* uma sequência não selecionada (`player_walk_hobble_forward`) permanece
  byte-a-byte idêntica;
* o pacote gerado continua parseável e com `CameraBoneName=Hero-Camera`.

## 8. Limitações e riscos

* O patch é específico para o `OLGame.upk` do Outlast 1 (UE3 868 / licensee 3).
  Versões diferentes (DLC, remaster, região) podem ter offsets diferentes; a
  ferramenta lê a estrutura dinamicamente, mas sempre valide com o seu arquivo.
* Substituir o pacote por um não comprimido aumenta o tamanho em disco
  (~21 MB). Se o jogo exigir o pacote comprimido, seria necessário recomprimir
  os chunks LZO — o `decompress.exe` fornecido só descomprime.
* `--mode all` pode congelar a câmera em cutscenes/ações scriptadas. Para uso
  normal, prefira `walk-run`.
* O patch não altera o executável, não requer DLL/ASI e é reversível
  restaurando o backup.

## 9. Resposta direta

* **O que causa o HeadBob?** A trilha de translação (e, em menor grau, rotação)
  do osso `Hero-Camera` nas animações de caminhada/corrida. A câmera é presa a
  esse osso; não há efeito procedural nem config.
* **Dá para remover só ao andar/correr?** Sim. Editando as 12 sequências
  cíclicas de walk/run (ou todas as `player_walk_*`/`player_run_*`), mantendo o
  resto intacto.
* **Dá para remover totalmente?** Sim. Editando todas as 339 sequências do Hero
  que possuem track de câmera (ou mudando o AnimSet globalmente, com risco de
  afetar outras translações).
* **Melhor abordagem:** achatar a translação (e opcionalmente a rotação) do
  osso `Hero-Camera` nas sequências escolhidas, como faz
  `tools/headbob_patch.py`.


