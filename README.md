# Outlast - Head Bob

Analise do head bob do Outlast (2013) e patcher para remove-lo do `OLGame.upk`.

## Conteudo

- [`ANALISE_HEADBOB.md`](ANALISE_HEADBOB.md) - como o head bob funciona no jogo
  (caminho da camera, bone `Hero-Camera`, onde ficam os keyframes e como remover).
- [`patcher/`](patcher/) - ferramenta com interface grafica para aplicar/restaurar
  o patch no `OLGame.upk`, com backup automatico.

## Uso rapido

1. Feche o Outlast.
2. Copie o conteudo de `patcher/` para
   `...\Steam\steamapps\common\Outlast\OLGame\CookedPCConsole\`.
3. Execute `run_patcher.bat` e escolha as opcoes.
4. Clique em **Aplicar alteracoes**. Para voltar ao original, use
   **Restaurar arquivo original**.

Detalhes, requisitos e solucao de problemas: [`patcher/README.md`](patcher/README.md).

## Resumo tecnico

O jogo le a posicao/rotacao da camera diretamente da bone `Hero-Camera` da
animacao (`Mesh.GetBoneLocation`/`GetBoneQuaternion`). Nao existe opcao de
configuracao para o head bob: o balanco esta gravado nos keyframes das 360
animacoes do AnimSet `03_Hero.Hero-01_AS` dentro do `OLGame.upk`.

O patcher acha a bone no `TrackBoneNames`, localiza as tracks de translacao e
rotacao de cada `AnimSequence` e deixa os keyframes constantes (media da
translacao e quaternion medio da rotacao) apenas nas animacoes escolhidas. Ele
nao altera tamanhos, offsets ou tempos das keys, e mantem um backup
`OLGame.upk.backup` do arquivo original.
