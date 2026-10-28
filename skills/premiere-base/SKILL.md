---
name: premiere-base
description: Base comum para qualquer trabalho no Adobe Premiere Pro pelo MCP Bridge na deNoise. Cobre conectar e diagnosticar o Bridge (somente leitura, ponte caída, sessão nova para carregar o MCP), pedir a autorização de ExtendScript, ler a sequência (dump e transcrição do .prproj), colocar clipes sem apagar vizinhos, efeitos via QE, keyframes com ease, limites do Bridge e as ferramentas locais (yt-dlp, ffmpeg, Swift). Use sempre que o pedido envolver Premiere, MCP Bridge, timeline, sequência, .prproj, "conecta no Premiere", ExtendScript ou B-roll na timeline, mesmo quando outra skill de cliente (docs-felipe, reels-felipe, timeline-bruno, fotos-produto-chz) também se aplicar. Nesse caso, carregue as duas.
---

# Premiere base: Bridge, leitura e escrita seguras

O Juliano é editor de vídeo e dono da deNoise. Trate-o de forma informal, em português, e nunca o chame de "senhor". Ele costuma falar por áudio, em mensagens longas: separe o que é **regra geral** do que é **pontual**.

Esta skill é a fundação técnica. As skills de cliente dizem **o que** editar; esta diz **como** mexer no Premiere sem quebrar nada.

| Arquivo | Conteúdo |
|---|---|
| `references/tecnico.md` | Como o Bridge e o ExtendScript se comportam: unidades, armadilhas e o que não dá pra fazer |
| `scripts/lib.jsx` | Funções ExtendScript: `T`, `getSeq`, `findItem`, `ensureBin`, `place`, `comp`, `prop`, `kf`/`setKeys`, `db`/`lvl`, `applySmoothUp`, `LABEL` |
| `scripts/dump_sequencia.jsx` | `dumpSeq(id, arquivo.tsv)`: todos os clipes, tempos, efeitos, escala/posição, volume e marcadores |
| `scripts/transcricao.py` | Lê a transcrição guardada no .prproj e devolve `words.json` (palavra → minutagem na timeline) + `texto.txt` |
| `scripts/sem_apoio.py` | Trechos longos só com o apresentador (pra cobrir com imagem) |
| `scripts/ease.py` | Curva do Smooth Caption Up frame a frame (`ease.json`) |
| `scripts/analisar_audio.py` | Tom, duração e subidas de música; pico de SFX; perfil de volume |
| `scripts/busca_imagens.py` | Busca de imagens grandes no Bing (URL + título) |
| `scripts/folha_contato.swift` | Folhas de contato de uma pasta de JPG + rostos (`faces.json`) |
| `scripts/rostos.swift` | Posição dos rostos em cada JPG (para anchor/crop) |
| `scripts/print_youtube.swift` | "Print" de vídeo do YouTube (capa, duração, avatar, título, canal, views) com dados reais |
| `scripts/preview_png.swift` | Prévia 960×540 de um PNG/JPG para conferir |

Chame os scripts pelo caminho completo: `~/.claude/skills/premiere-base/scripts/...`.

## 1. Conectar (sempre o primeiro passo)

1. `verify_premiere_connection`. Ele diz a versão, o projeto, a sequência ativa e se está em **`readOnly`**.
2. **`readOnly: true`**: dá pra ler, mas não pra editar. Peça pro Juliano: (a) tirar o somente leitura do projeto (o cadeado em File, ou o projeto aberto de um local travado) e (b) conferir se o painel Window › Extensions › MCP Bridge está em "Connected". Não tente editar antes.
3. **Ponte fora do ar**: espere em background e verifique **uma vez**. Se continuar fora, peça pra abrir o painel MCP Bridge e clicar em **Start Bridge**. Não fique tentando em loop.
4. **As ferramentas `premiere-pro` não aparecem na sessão**: o Claude Code só carrega servidor MCP novo ao **abrir uma sessão nova**. Diga isso; não reinstale nada.
5. **Reinstalar/atualizar** só se ele pedir (`npm install -g adobe-premiere-pro-mcp@latest && premiere-pro-mcp --install-cep`, depois `premiere-pro-mcp --doctor`). O servidor está registrado como `premiere-pro` em `~/.claude.json`.
6. **ExtendScript precisa de autorização explícita em cada sessão.** Peça na primeira mensagem, junto com as outras confirmações. Sem isso o trabalho vira milhares de chamadas.

Muitas ferramentas do Bridge ficam escondidas: use `search_tools` (consulta em linguagem natural ou regex) → `get_tool_schema` → `invoke_tool`. Não invente nomes de ferramenta.

## 2. Regras da casa (valem para todo cliente)

- **V1/A1 são do Juliano.** A decupagem, os cortes de fala e os J/L-cuts (Cmd+Shift+D) são dele. Não remova, não apare e não mova nada nelas, a não ser que ele peça com essas palavras. Se ele travou a faixa, ótimo; se não, trate como travada.
- **Trabalhe numa cópia.** Antes de uma etapa grande, duplique a sequência (`Nome · v01`, `Nome_BACKUP_antes_<etapa>`). Nunca edite a original sem ele pedir.
- **Ele mexe ao mesmo tempo que você.** Antes de cada lote, confira `app.project.activeSequence` e use o ID da sequência. Se a contagem de clipes mudar sozinha, **pare e pergunte** antes de remover qualquer coisa. Não reverta mudanças dele.
- **Lotes de ~20 operações, um por vez**, conferindo a contagem entre eles. Lotes em paralelo derrubam o Bridge. Comandos que passam de 45 s continuam rodando: espere e confira.
- **Não salve o projeto** sem ele pedir. Diga no fim se está salvo ou não.
- **Nunca apague arquivo.** O que sobrar vai para `99. Temp` da leva ou `99. _Revisar` na raiz.
- **Para trocar mídia já colocada**: regere o arquivo com o **mesmo nome, na mesma pasta**, e ele relinka. Não recoloque no Premiere: ele pode ter movido clipes.
- **Defina a label do item no projeto antes de colocar** (a cor do clipe já na timeline só muda pela UI).
- **Você não ouve o áudio.** Diga sempre o que conferiu (frames exportados, contagens) e o que ele precisa escutar.

## 3. Ler o projeto

1. `dumpSeq(id, '<scratchpad>/dump.tsv')` com a `lib.jsx` carregada (padrão `$.evalFile(lib); $.evalFile(script); return main();`). O arquivo sai com `\r`: `tr '\r' '\n'`.
2. `python3 transcricao.py PROJETO.prproj dump.tsv PASTA` → `words.json` e `texto.txt`. Leia o texto inteiro antes de planejar.
3. Texto de Graphics não aparece no dump: exporte frames (`export_frame` ou `exportFramePNG` do QE, que só funciona na sequência **ativa**) e olhe.

## 4. Escrever na timeline (resumo; detalhes em `references/tecnico.md`)

- **Grade de frames.** Todo início/fim de clipe em frame inteiro da sequência (`seq.timebase` = ticks por frame; 254016000000 ticks/s). Tempo em segundos solto (ex.: 168,001 s) deixa vão de fração de frame entre clipes colados = "frame fantasma". O `place()` da `lib.jsx` já encaixa (`snapTicks`, `TT`); para clipe colado no anterior, use o mesmo tick. Depois de cada lote, confira: nenhum clipe fora da grade e nenhum vão < 3 frames.
- **Sempre** defina in/out do item antes do `overwriteClip`, inclusive em stills, Black Video e subclips. Sem isso o clipe entra com a duração inteira e **apaga tudo que vem depois na faixa**. Use `place()` da `lib.jsx`.
- Vídeo por cima de imagens já colocadas pode **comer frames ou apagar vizinhos**: depois de cada lote, confira clipe por clipe contra o plano.
- Clipe de vídeo com áudio entra nas duas faixas. B-roll baixado entra **só com imagem** (baixe sem áudio ou remova o áudio do item).
- Efeitos só via QE. Keyframes **nunca lineares**: use `ease.json` + `setKeys`. Ao mudar a duração de um clipe, refaça os keyframes e realinhe os SFX.
- SFX: início = corte − pico (picos em `references/tecnico.md`).

## 5. Material da internet

- **Vídeo do YouTube**: `~/.local/bin/yt-dlp` (fora do PATH; config em `~/.config/yt-dlp/config` já usa Node, ffmpeg e H.264+AAC). Para B-roll: `-f "bv*[vcodec^=avc1][height<=1080]"` (só imagem) e confira a resolução depois, porque às vezes cai em 360p. 4K só com `-f "bv*+ba"` (VP9/AV1). ffmpeg/ffprobe em `~/.local/bin`.
- **Imagens**: `busca_imagens.py` + `curl` para a pasta da leva. Nunca execute nada baixado.
- **Sem banco de imagem nem imagem de IA.** Alamy, iStock, Adobe Stock, Getty, Freepik, Vecteezy e Dreamstime estão fora, e nada com marca d'água. Se não existir imagem real do assunto, o trecho fica sem imagem e você avisa.
- **Chrome**: use só a extensão Claude in Chrome ou o navegador embutido. Nunca rode o binário do Chrome pelo terminal (headless trava o Chrome dele) e não dispare downloads pelo Chrome (ele pode estar com "Perguntar onde salvar" ligado). Baixe com `curl`.
- **Google Drive local travado**: ler arquivo do Drive sincronizado pode dar timeout e importar por ali **trava o Premiere**. Baixe pelo conector do Drive (`download_file_content`) para uma pasta local da leva antes de importar.

## 6. Onde as coisas ficam

Estrutura de cada cliente: `00. Clientes/01. Ongoing/<Cliente>/02. Vídeos/<MM. Mês>/Leva NN - Desc/{00. Projeto, 01. Brutos, 02. Brolls, 03. Renders, 04. Capas, 99. Temp}` (Felipe, Vivi e Calibase têm o formato antes do mês). Vídeo baixado junto de um projeto é **B-roll** (`02. Brolls`), não referência.

Assets: SFX em `02. Ferramentas/01. Assets edição/02. SFXs` (tonais em `Tonal Sounds/`, nos 12 tons), presets em `01. Assets edição/03. Presets`.

## 7. Fechar a etapa

Mostre o que mudou com números (clipes por faixa, cobertura, minutagens), frames exportados dos pontos-chave, o que **não** conseguiu verificar, se o projeto foi salvo e onde ficaram os arquivos novos. Se aprender algo técnico novo do Bridge, acrescente em `references/tecnico.md`.
