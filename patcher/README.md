# Outlast - Head Bob Patcher

Remove o **head bob** (balanco da camera) do Outlast, com opcao de remover
tambem o balanco de **respiracao** quando o Miles esta parado.

O patcher edita o `OLGame.upk` da pasta `CookedPCConsole`, cria backup do
arquivo original e permite restaurar tudo depois.

---

## 1. Como usar

1. Feche o Outlast (e o Steam, se possivel).
2. Copie **todo o conteudo desta pasta** (`patcher/`) para:
   `...\Steam\steamapps\common\Outlast\OLGame\CookedPCConsole\`
   (o `OLGame.upk` deve ficar ao lado do patcher).
3. Execute `run_patcher.bat` (ou `python OutlastHeadBobPatcher.py`).
4. Escolha as opcoes e clique em **Aplicar alteracoes**.
5. Abra o jogo. Para voltar ao original, use **Restaurar arquivo original**.

> O `decompress.exe` (Gildor's PackageUnpack) deve continuar ao lado do
> patcher: ele e usado somente se o `OLGame.upk` estiver comprimido.

### Requisitos

- Windows 10/11.
- Python 3.8 ou superior com tkinter (instalador oficial do python.org ja inclui).
- O jogo **Outlast** (2013) da Steam, com o `OLGame.upk` original.

---

## 2. Opcoes da interface

### (checkbox) Remover o head bob de respiracao? (recomendado)

Remove o balanco da camera quando o Miles esta **parado**, agachado, encostado,
na cama, no armario ou com a camera na mao. Sem essa opcao, o balanco de idle
(respiracao) continua.

### Modo de remocao

| Modo | O que remove | Animacoes aprox. |
|---|---|---|
| **Caminhada + Corrida (padrao)** | Ciclos normais de andar/correr: frente, tras, laterais e variantes na agua. | 12 |
| **Caminhada + Corrida (todas)** | Toda animacao com `walk` ou `run` no nome: agachado, mancando, ferido, escadas, pulos, transicoes. | 51 |
| **Somente caminhada** | Todas as animacoes de caminhada (`walk`). | 41 |
| **Somente corrida** | Todas as animacoes de corrida (`run`). | 10 |
| **Todas as animacoes** | Todas as 360 animacoes do Miles (idle, walk, run, crouch, pulos, quedas, interacoes, fatalities). | 360 |

As contagens sao do `OLGame.upk` PC (Outlast + Whistleblower). O patcher mostra
a contagem real no log ao aplicar.

---

## 3. Backup e seguranca

- Na primeira aplicacao o patcher cria **`OLGame.upk.backup`** com o arquivo
  original, e so o cria **uma vez** (nunca sobrescreve um backup existente).
- Se ja existir um backup, ele e usado como fonte limpa: aplicar de novo com
  outro modo **nao** empilha patches.
- Se o backup estiver ausente mas o `OLGame.upk` aparentar ja estar modificado
  (um grupo inteiro de animacoes sem balanco), o patcher **se recusa** a criar
  backup e pede para verificar os arquivos na Steam.
- `Restaurar arquivo original` renomeia `OLGame.upk.backup` de volta para
  `OLGame.upk`, substituindo o modificado, e apaga o registro de estado.
- O jogo precisa estar fechado para gravar/restaurar (senao o Windows bloqueia
  o arquivo).

Arquivos criados na pasta:

```
OLGame.upk              -> pacote modificado (ou original restaurado)
OLGame.upk.backup       -> copia do OLGame.upk original
OLGame.headbob.json     -> registro do patch aplicado (opcoes e contagem)
```

---

## 4. Sobre a compressao do OLGame.upk

O `OLGame.upk` do Outlast e um pacote UE3 **comprimido**. Para editar, o patcher
usa o `decompress.exe` incluido para gerar uma copia descomprimida, aplica o
patch e grava essa copia como `OLGame.upk`.

- O pacote final fica **nao comprimido** (o `decompress.exe` limpa o flag de
  compressao do cabecalho). E o mesmo tipo de pacote que o UE3 usa para mods
  cookados no UDK; o engine carrega pacotes assim normalmente.
- O arquivo final fica maior (~85 MB em vez de ~64 MB); isso e normal.
- O backup mantem o arquivo original comprimido, entao `Restaurar` devolve o
  jogo ao estado de fabrica caso algo nao funcione.
- Se o jogo nao abrir com o pacote descomprimido (nao e esperado), use
  **Restaurar arquivo original** e avise para ajustarmos o fluxo de
  recompressao.

---

## 5. Linha de comando (avancado)

```bat
python OutlastHeadBobPatcher.py --cli --package OLGame.upk --analyze
python OutlastHeadBobPatcher.py --cli --package OLGame.upk --mode default --breathing --output OLGame.patched
python OutlastHeadBobPatcher.py --cli --package OLGame.upk --mode walk_run_all --apply
python OutlastHeadBobPatcher.py --cli --package OLGame.upk --restore
```

`--output` nao altera o arquivo original; `--apply` usa o fluxo com backup.

---

## 6. Como o head bob funciona no Outlast (resumo tecnico)

1. `OLPlayerController.GetPlayerViewPoint()` chama `OLHero.GetCamera()`.
2. `OLHeroCamera` (classe nativa) atualiza a visao lendo **diretamente a bone
   `Hero-Camera` da animacao**: `Mesh.GetBoneLocation("Hero-Camera")` e
   `Mesh.GetBoneQuaternion("Hero-Camera")`.
3. Portanto o balanco nao vem de uma variavel de configuracao: ele esta gravado
   nos **keyframes** dos `AnimSequence` do AnimSet `03_Hero.Hero-01_AS`.
4. O patcher localiza o AnimSet dentro do `OLGame.upk` (pacote seekfree que
   contem as animacoes), acha o indice da bone `Hero-Camera` em
   `TrackBoneNames` e achata os keyframes de translacao e rotacao dessa bone
   somente nas animacoes escolhidas.
5. No esqueleto (`RefSkeleton` de `Miles_beheaded`), a `Hero-Camera` e filha do
   `Hero-Root` (indice 0), **nao** da cabeca/pescoco. Por isso a animacao do
   corpo nao move a camera: toda a oscilacao visivel vem da track local da
   camera, e achatá-la remove o head bob por completo sem congelar o corpo.

Formato usado (UE3 per-track compression, Outlast):

- `CompressedTrackOffsets`: 4 inteiros por bone: `transOffset, transKeys,
  rotOffset, rotKeys`.
- Cada key de translacao/rotacao ocupa **12 bytes** (3 floats; no caso da
  rotacao o W e reconstruido).
- Quando `keys > 1`, depois das keys vem um array de `keys` bytes com os tempos
  (alinhado a 4 bytes). O patcher **nao altera** nem tamanhos nem tempos.
- Translacao e rotacao sao substituidas pela media (translacao) / quaternion
  medio normalizado (rotacao), mantendo a posicao e a orientacao base da camera
  e eliminando a oscilacao.

Observacao: 5 animacoes de fatality (`player_fatality_xplod_*` e
`player_grab_fatality_groom`) usam um layout de tracks diferente; elas sao
ignoradas com seguranca (aparecem como `skipped_layout` no log).

---

## 7. Solucao de problemas

- **"decompress.exe nao foi encontrado"**: mantenha o `decompress.exe` na
  mesma pasta do patcher.
- **"Nao foi possivel gravar/restaurar"**: feche o jogo (e o Steam) e tente de
  novo; o Windows mantem o arquivo aberto enquanto o jogo roda.
- **"OLGame.upk parece ja ter sido modificado"**: restaure pela Steam (Verificar
  integridade dos arquivos) e aplique novamente.
- **Antivirus**: alguns antivirus reclamam de executaveis que rodam
  `decompress.exe`; adicione a pasta do jogo a excecao, se necessario.

---

## 8. Aviso

Mod nao oficial, sem relacao com a Red Barrels. Use por sua conta e risco.
Sempre mantenha o backup (`OLGame.upk.backup`) enquanto estiver testando.
