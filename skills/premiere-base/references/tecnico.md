# Notas técnicas: Premiere via MCP Bridge e ExtendScript

Tudo aqui foi testado entre 10 e 19/10/2026 (Premiere 26.5). Acrescente o que descobrir de novo.

## Ritmo e segurança
- Timeline pesada (mais de 300 clipes): lotes de **~20 operações**, um por vez, conferindo a contagem. Paralelo derruba o Bridge.
- Antes de mexer, confirme `app.project.activeSequence` e use sempre o ID da sequência (o usuário troca de aba).
- **Ao trocar um clipe por uma versão nova, use a posição atual do clipe antigo** (procure pelo nome na hora), nunca uma minutagem guardada: ele redecupa entre rodadas e tudo desliza.

## Padrão de script
- Escreva o `.jsx` no scratchpad com `function main(){...}` e chame `$.evalFile(lib.jsx); $.evalFile(script.jsx); return main();`. O `evalFile` sozinho devolve `undefined`.
- Acentos dentro de `.jsx`: use escapes `á` (o evalFile não lê UTF-8).
- Erros: `try{...}catch(e){return 'ERR '+e+' line '+e.line}`.
- Arquivos escritos pelo ExtendScript saem com `\r`: `tr '\r' '\n'`.
- `eval` e `JSON` são barrados pelo Bridge: trate JSON como string (regex).

## Unidades
- Tempo: `Time.seconds`; ticks = 254016000000 por segundo (`importMGT` quer ticks **como string**).
- **Motion Position e Anchor são normalizados (0–1)**, inclusive no `set_clip_position` do Bridge, que **não** usa pixels.
- Fill: escala = `max(W_seq/w, H_seq/h)·100`. Para enquadrar no rosto mantendo o Fill: `pos = 0,5 + (anchor − 0,5)·dim·scale/frame`.
- Still: a escala é relativa ao quadro (num 1080 de largura, 100% = largura do quadro). Pra cobrir a metade de cima de um 9:16: escala = 88,9 × w/h.
- Stills começam em tempo de mídia 3600 s (o inPoint de um PNG não é 0).
- `split_clip` usa tempo relativo ao clipe: prefira `razor_timeline_at_time`.
- `add_to_timeline_batch` com sourceIn/Out em still deixa 1 frame a menos: corrija com `trim_clip`.
- Label: `set_color_label` no **item do projeto** antes de pôr na timeline (Rose = 6, Mango = 7, Magenta = 11).

## Leitura
- Transcrição: dentro do .prproj (gzip), em `<TranscriptData Encoding="base64">`, uma por mídia. Os in-points dos cortes ficam em AudioClipTrackItem → SubClip → AudioClip `<InPoint>`. Use `scripts/transcricao.py`.
- Texto de Graphics (Essential Graphics) não é legível por script: exporte frames.
- Clipes feitos com o **Remix** aparecem sem projectItem (null).
- Ler o XML do .prproj direto (gunzip) é útil pra projetos com mídia offline ou de outro computador.

## Escrita
- Colocar: `item.setInPoint(t,4); item.setOutPoint(t2,4); track.overwriteClip(item, start)` e depois `clearInPoint/clearOutPoint`. **Sempre** com in/out, senão o clipe apaga o resto da faixa. O overwrite encaixa no frame: procure o clipe colocado com tolerância de ~0,05 s.
- Mover: `clip.move(T(delta))`. `clip.start = T(x)` estica a cabeça sem mudar o inPoint (acerte com `clip.inPoint`). `clip.end = T(x)` apara o fim. Apagar: `clip.remove(false,false)`.
- **Não dá pra copiar um clipe da timeline** (Graphic, nest colado, etc.): o script só coloca **itens do projeto**. Para um conjunto pronto do usuário (ex.: transição em Graphics), deixe marcadores "Colar …" e ele cola com Cmd+V; ou peça que ele transforme o conjunto numa nested sequence, que vira item do projeto.
- **Nunca una `Graphic`** ao juntar picotes: todos têm o mesmo nome e textos diferentes.
- Faixas novas: QE `seq.addTracks(nVideo, idxV, nAudio, 1, idxA, 0, 0)`. Inserir faixas desloca os índices das de cima.
- Marcadores: `seq.markers.createMarker(t)`, depois `name`, `comments` e `end` (em segundos). `m.end = T(...)` derruba o script.
- Volume: `db()` da `lib.jsx`. Níveis por keyframe com `lvl()`.

## Efeitos (só via QE)
- `qe.project.getVideoEffectByName('Transform' | 'Gaussian Blur' | 'Gaussian Blur (Legacy)' | 'Lumetri Color' | 'Lens Distortion')` + `qeItem.addVideoEffect(fx)`. O QE só funciona na **sequência ativa**; o DOM funciona por nome.
- matchNames: Transform = `AE.ADBE Geometry`; Gaussian Blur = `AE.ADBE Gaussian Blur 2` (o "Gaussian Blur" novo aparece como `AE.Impact_Blur_FX`, com `Amount`); Lumetri = `AE.ADBE Lumetri`; Opacity = `AE.ADBE Opacity`; Motion = `AE.ADBE Motion`.
- Transform da Adjustment Layer: ligue `Uniform Scale` e anime `Scale Height`. Desligue "Use Composition's Shutter Angle" para usar `Shutter Angle` próprio.
- Lumetri por índice: 14 temp, 15 tint, 16 sat, 20 contraste, 21 highlights, 22 shadows, 23 whites, 24 blacks, 40 faded, 42 vibrance, 43 sat criativa, 110 vinheta, 113 feather.
- Crop: está no componente Motion em alguns projetos ("Crop Top/Bottom") ou como efeito Crop; leia com `prop()` antes de setar.

## Keyframes
- **Nunca lineares.** O ExtendScript não ajusta alças de bezier: grave a curva frame a frame (`scripts/ease.py` → `ease.json`, `setKeys`).
- `set_keyframe_interpolation` do Bridge **zera o valor do keyframe**: não use. `setInterpolationTypeAtKey(t,5)` (bezier) funciona no DOM, mas as alças ficam no padrão.
- `setTimeVarying(false)` apaga os keyframes antigos.

## Texto
- `add_text_overlay` com Basic Title.mogrt diz que funcionou, mas renderiza vazio.
- **Texto editável funciona** com um .mogrt **feito no After Effects**: `seq.importMGT(caminho, String(seg*254016000000), vIdx, aIdx)` + `clip.getMGTComponent()`. A propriedade de texto devolve JSON: troque `"textEditValue":"..."` e `"fontEditValue":["Inter-Black"]` por regex e `setValue(v,true)`.
- .mogrt feito no Premiere vira Graphic nativo, com `Source Text` binário: qualquer `setValue` deixa em branco.
- Alternativa sempre segura: PNG gerado em Swift/AppKit.

## Limitações (não tente, avise)
- **Adjustment Layer não se cria por script** (o `add_adjustment_layer` gera um PNG transparente inútil). Peça para criar pela UI; depois ache com `item.isAdjustmentLayer()`.
- Aplicar preset (.prfpset) ou Remix: leia o preset e reproduza os valores.
- Transições de áudio (Cmd+Shift+D) não são confiáveis por script.
- Legendas (caption track) o Bridge não lê nem move: gere uma lista de ajustes para ele aplicar.
- Cor de clipe já na timeline: só pela UI.
- Área de transferência (Cmd+C/Cmd+V) não funciona em segundo plano.

## SFX (picos medidos, em s desde o início do arquivo)
Impact 01 = 0,34 · 02 = 0,54 · 03 = 0,20 (**banido**, "parece um sino") · 04 = 0,66 · 05 = 0,94 · Woosh 01 = 0,40 · 02 = 0,42 · Riser Long 01 = 2,40 · 02 = 1,94 · 03 = 4,80 · 04 = 5,52 · 05 = 4,48 · Riser Super 01 = 1,84 · Riser Sword = 1,70 · Kodak shutter = 0,30 · Vocal Cadence = 5,4. Posicione com início = corte − pico.

## Ferramentas locais
- `afconvert`/`afinfo` (macOS) para áudio; Swift + AppKit/Vision/AVFoundation para imagem, rostos e vídeo.
- `~/.local/bin/yt-dlp`, `~/.local/bin/ffmpeg`, `~/.local/bin/ffprobe`, `~/.local/bin/gh` (todos fora do PATH).
- Fontes: Inter instalada no sistema (Google Fonts). Se faltar Inter Black, use Bold + stroke −4,5.
- Sem PIL, sem fontTools instalados. Não instale pacotes sem pedir.

## Aprendido em 20/10/2026 (Calibase, Micro VSL ganchos)
- `verify_premiere_connection` sempre devolve `readOnly: true` (está fixo no código do Bridge, em discovery.js). Não quer dizer que o projeto está travado.
- B-roll de vídeo **sem áudio**: `item.createSubClip(nome, Time in, Time out, 1, 1, 0)` (takeAudio = 0) e coloque o subclipe. Assim o overwrite não mexe nas faixas de áudio.
- `getMediaPath()` pode vir com `/Volumes/Macintosh HD` na frente e com acento decomposto (NFD). Para achar um item pelo caminho, compare sem esse prefixo e sem acentos.
- `importFiles` às vezes não importa nada e mesmo assim devolve true: confira a contagem do bin depois.
- PNG regerado com o mesmo nome só atualiza no Premiere depois de `item.refreshMedia()`.
- A Poppins da Adobe Fonts fica em `~/Library/Application Support/Adobe/CoreSync/plugins/livetype/.r/.37522.otf`. Registre com `CTFontManagerRegisterFontsForURL` para usar no Swift.

## Aprendido em 21/10/2026 (CHZ, matéria da Vans)
- **Não usar WKWebView (Swift) para print de site**: dispara pedido de senha do Keychain no Mac do Juliano. Para matéria, baixe o HTML com `curl` e monte o cartão com o texto literal; sites com Cloudflare (shop-eat-surf, fashionista) bloqueiam curl.
- Recorte de produto sem fundo: Vision `VNGenerateForegroundInstanceMaskRequest` + `generateMaskedImage(... croppedToInstancesExtent: true)` funciona bem em tênis.
- `NSBitmapImageRep` lido de PNG não aceita `setColor`: desenhe num rep novo RGBA e mexa em `bitmapData`.
- **Frame fantasma (21/10/2026):** 88 de 129 fotos tinham início/fim fora da grade de frames (tempos em segundos tipo 168,001) e havia 45 vãos de fração de frame entre fotos coladas. Correção na `lib.jsx`: `snapTicks(seg)` arredonda para `Math.round(seg*254016000000/timebase)*timebase`, `TT(ticks)` cria o Time por ticks e `place()` usa os dois. Para conferir: `Number(clip.start.ticks) % Number(seq.timebase) == 0` em todos e `(start − end anterior)/timebase` nunca entre 0 e 3.

## Aprendido em 22/10/2026 (deLegenda no deCupagem)
- Legenda nativa a partir de SRT: `importFiles([srt], true, bin, false)` e `seq.createCaptionTrack(item, 0, Sequence.CAPTION_FORMAT_SUBTITLE)` funcionam no 26.5. O DOM não expõe as faixas de legenda (`seq.captionTracks` não existe): confira pelo `exportFramePNG`, que mostra a legenda. SRT com BOM UTF-8 mantém os acentos.
- `execute_extendscript` recusa script inline com `eval(...)` ("Script validation failed"): grave um `.jsx` com `function main()` e chame `$.evalFile(lib); $.evalFile(teste); return main();`.
- **`place()` come 0,2 s do vizinho (27/10/2026):** o out-point vai com +0,2 s de folga e o `overwriteClip` apaga esse pedaço do clipe que já estava logo depois; o `place` corta o fim do novo, mas o início do vizinho fica comido (vão de ~4 frames). Ao colocar um clipe colado **antes** de outro já existente, depois devolva o início do vizinho: `viz.start = TT(novo.end.ticks)` e confira que o `end` dele não mudou.
- **Vários projetos abertos:** `app.openDocument()` abre outro .prproj e o torna `app.project`; `app.projects[i].sequences` de um projeto que não é o ativo vem vazio. O `path` volta com acento decomposto (NFD): compare pelo `name`. Feche com `closeDocument(0,0)` (sem salvar). O texto de Graphics não sai pelo `getValue()` (vem binário): leia o `InstanceName` do componente Text no XML do .prproj.
