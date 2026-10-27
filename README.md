# Outlast HeadBob — análise e remoção

Este repositório contém uma investigação técnica do HeadBob de **Outlast** e uma
ferramenta que o remove diretamente das animações do jogo, sem DLL, sem
executável modificado e sem configuração manual.

## Resultado da investigação

O HeadBob é causado pela **trilha de translação do osso `Hero-Camera`** nas
animações de caminhada e corrida:

* `OLHeroCamera.CameraBoneName = Hero-Camera` prende a câmera a esse osso.
* O `AnimSet Hero-01_AS` usa `bAnimRotationOnly=False` e
  `UseTranslationBoneNames=[Hero-Camera, Hero-L-UpperArm]`; a câmera é um dos
  únicos dois ossos com translação animada.
* Em `player_walk_forward` a câmera oscila `ΔZ=1,25 cm`, `ΔX=3,10 cm` e gira
  ~0,84°. Em `player_run_forward`, `ΔZ=1,64 cm` e ~2,77°.
* Não existe variável/config/nó de AnimTree de HeadBob. O `ShakeData` da câmera
  é um shake curto de impacto, não o bob contínuo.

O relatório completo, com offsets e provas, está em
[`docs/ANALISE_HEADBOB.md`](docs/ANALISE_HEADBOB.md).

## Uso rápido

Requisitos: Python 3.8+ (somente biblioteca padrão).

```bash
# Ver as animações e as amplitudes de bob
python3 tools/headbob_patch.py --list --mode walk-run

# Remover o bob ao andar/correr (12 animações, translação + rotação)
python3 tools/headbob_patch.py --mode walk-run

# Resultado:
#   build/OLGame_headbob_fixed.upk
#   build/headbob_report.json
```

Para instalar: faça backup de `CookedPCConsole/OLGame.upk`, renomeie
`build/OLGame_headbob_fixed.upk` para `OLGame.upk` e substitua o arquivo.

### Modos

| Modo | O que altera |
|---|---|
| `walk-run` (padrão) | 12 animações cíclicas de walk/run e variantes `_water` |
| `walk-run-all` | todas as `player_walk_*` e `player_run_*` (inclui hurt/hobble/door) |
| `walk` / `run` | somente as animações de walk ou run |
| `all` | todas as 339 sequências do Hero com track de câmera |

Opções: `--translation flatten|none`, `--translation-anchor mean|first`,
`--rotation flatten|none`, `--match REGEX`, `--animset`, `--bone`, `--dry-run`,
`--list`.

## Validação

```bash
python3 -m unittest discover -s tests -v
```

Os testes conferem que:

* o pacote gerado mantém tamanho e header;
* somente bytes dos tracks da câmera são alterados;
* a translação/rotação da câmera fica constante nas animações escolhidas;
* animações não selecionadas permanecem byte-a-byte idênticas.

## Estrutura

```
tools/outlast_upk.py       leitor do pacote UE3 868 do Outlast
tools/headbob_patch.py     patcher do HeadBob
tests/                     testes de integridade do patch
docs/ANALISE_HEADBOB.md    análise técnica completa (português)
uc/                        scripts descompilados usados como referência
upk/unpacked/OLGame.upk    pacote de entrada (não comprimido)
```

## Limitações

* O patch é específico para o `OLGame.upk` do Outlast 1 (UE3 868 / licensee 3).
* O pacote de saída é não comprimido (~85,6 MB em vez de 64,7 MB).
* `--mode all` pode congelar a câmera em cutscenes; para uso normal use
  `walk-run`.
* Shakes de dano/queda não são removidos (não fazem parte do HeadBob).
