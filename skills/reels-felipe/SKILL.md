---
name: reels-felipe
description: Edita os Reels/Shorts verticais do Felipe (cliente do Juliano, biografias curtas de criadores como Mark Rober, Sidemen, Colin & Samir, Hacksmith, Yes Theory) no Adobe Premiere pelo MCP Bridge, no padrão aprovado em outubro de 2026. Cobre: B-roll com ~70% de cobertura (trechos de vídeo do YouTube, fotos reais e prints de YouTube no exato momento citado), tela dividida (mídia em cima, Felipe embaixo, fundo da cor da mídia), animação de entrada, sound design (gancho com tensão, Riser Sword no clímax, cordas da Class Act no final, músicas mescladas entre Reels) e lista de ajustes de legenda. Use sempre que o pedido envolver Reels, Shorts, vídeo vertical ou "leva de shorts" do Felipe, Shorts Outubro/Setembro/Agosto, tela dividida, B-roll ou música de Reel, mesmo que o usuário não cite esta skill. Para documentários longos do Felipe, use docs-felipe.
---

# Reels do Felipe

Carregue também a skill **premiere-base** (conexão, ExtendScript, scripts e armadilhas do Bridge). Trate o Juliano de forma informal e nunca o chame de "senhor".

O Felipe grava Reels de 1–2 min contando a história de um criador. O Juliano faz a decupagem (V1/A1) e os punch-ins. A skill faz **cerca de 70% da edição mecânica**: B-roll, tela dividida, animação, música e a lista de legendas. Depois o Juliano finaliza.

| Arquivo | Conteúdo |
|---|---|
| `references/padrao.md` | Números exatos: tela dividida, animação, música (níveis e faixas), legendas |
| `references/aprendizado.md` | **Leia primeiro.** O que o Juliano aprovou e o que corrigiu, leva por leva |

Scripts: os da premiere-base (`~/.claude/skills/premiere-base/scripts/`).

## Antes de começar
Confirme numa mensagem só:
1. **Projeto e sequência** abertos, Bridge conectado e sem `readOnly`.
2. **Autorização de ExtendScript** nesta sessão.
3. **Quais Reels** da sequência (ele costuma juntar 5 ou 6 numa sequência só, um depois do outro) e onde está cada CTA. Os clipes de CTA se repetem entre Reels e **fazem parte do Reel**.
4. **Etapas desta rodada.** Ele costuma pedir em etapas (B-roll → tela dividida → música). Não faça a próxima sem ele pedir.

Faça um backup da sequência antes de cada etapa (`Nome_BACKUP_antes_<etapa>`). V1/A1 são dele.

## Fluxo

### 1. Ler
`dumpSeq` + `transcricao.py` (premiere-base). Leia o texto inteiro de cada Reel e marque: o **gancho** (primeiros ~3 s), os **nomes, vídeos e números citados**, os **clímax** (ex.: "1 bilhão de dólares", "mais de 1 milhão de inscritos") e a frase de efeito que fecha cada clímax.

### 2. Planejar o B-roll e mostrar
Meta: **~70% do tempo com imagem ou vídeo** (na leva aprovada, 108 clipes em 5 Reels, 69–74% por Reel). O Felipe fica sozinho só nos trechos de opinião e no CTA.
- **Ele cita um vídeo específico** → o trecho exato daquele vídeo, no momento da fala, **e** um print do YouTube no exato momento em que cita (`print_youtube.swift`, dados reais do `yt-dlp --dump-json`). Se o vídeo não existe mais, use o real mais próximo e **avise**. Nunca invente um print.
- **Não cita** → um trecho genérico do canal da pessoa, só pra mostrar como é o conteúdo.
- **Um vídeo principal por pessoa**, com vários trechos espalhados (4 s aqui, 6 s ali). Segundo vídeo só se precisar muito ou se ele citar outro.
- Trechos de **1–5 s dentro de um mesmo plano** (sem corte de cena no meio).
- **Fotos reais** (`busca_imagens.py`): a pessoa, o momento, prints de matéria, thumbs, posts. Nada de banco de imagem nem IA. Sem foto real, o trecho fica sem imagem.
- Alternar foto e vídeo: imagem parada o tempo todo cansa.

Mostre o plano (minutagem → o que entra → de onde vem) antes de baixar tudo, se ele estiver por perto. Se ele disse para seguir, siga.

### 3. Baixar e colocar
- Vídeo: `~/.local/bin/yt-dlp -f "bv*[vcodec^=avc1][height<=1080]"`, **só imagem**. Confira a resolução (às vezes cai em 360p).
- Arquivos na leva: `02. Brolls/Videos Reels/<Reel>/`, `02. Brolls/Imagens Reels/<Reel>/`, `02. Brolls/Prints YouTube/`. Nome com a minutagem: `010_00m58s_colin-and-samir-interview.jpg`. No projeto: bins `30 IMAGENS / <Leva> - Videos | Prints | Fundos`.
- Coloque em lotes, sempre com in/out (`place()`), e **confira clipe por clipe** depois de cada lote: vídeo por cima de imagem já colocada come frames e apaga vizinhos.
- Cada mídia entra **na palavra** que ela ilustra e encosta na próxima.

### 4. Tela dividida
Padrão atual em `references/padrao.md`. Em resumo: durante cada B-roll, a mídia ocupa a **metade de cima** e o Felipe desce para a **metade de baixo**. Fora dos B-rolls ele volta pra tela cheia.
- Fotos e vídeos **preenchem** a metade de cima, com Crop Bottom pra não invadir o Felipe. Nas fotos com gente, o corte lateral segue os rostos (`rostos.swift`).
- Mídia pequena ou de fundo liso (gráfico, print, logo, produto em fundo branco, thumb com texto) entra **inteira e legível**, com até 92% da largura, sobre um **fundo da mesma cor da borda da mídia** cobrindo a metade de cima.
- Fundos numa faixa abaixo das mídias (crie a faixa com QE). Fundos gerados em PNG ficam em `02. Brolls/Fundos tela dividida`.
- As trocas caem nos cortes da V1 sempre que possível: assim o Felipe só muda a posição fixa, sem keyframe.

### 5. Animação
- Entrada padrão (= Smooth Caption Up) nos Graphics e nos B-rolls pequenos: Gaussian Blur 35→0 e Opacity 0→100 em 0,27 s; Position Y 0,5776→0,5 em 0,57 s. Use `ease.json` + `applySmoothUp`.
- B-roll lateral: 2 keyframes de Position X (direita→centro ou esquerda→centro) com ease.
- **Ken Burns** (+4–8% de escala) só em B-roll de tela cheia.
- Nunca keyframe linear.

### 6. Música e sound design
Detalhes e níveis em `references/padrao.md`. A lógica:
1. **Gancho com tensão**: música mais alta (Violin Resonance, Brass ou Piano). Às vezes o Brass pula de trecho com um Riser Sword no meio do gancho.
2. **Depois do gancho a tensão baixa**: música sob a voz (~−15 dB), com crossfades.
3. **Sobe de novo até cada clímax**: a música cresce antes; o **Riser Sword termina exatamente no corte do clímax**.
4. **Depois do impacto, quase silêncio** na frase de efeito que fecha o clímax, pra ela ser ouvida.
5. **Final**: cordas da *Class Act Reprise* (Strings 1, e Strings 2 alinhada pelo mesmo offset) do clímax até 1–3 s depois do fim da fala.
6. **CTA**: a música continua 2–4 s dentro do CTA e some. O CTA fica sem música.
- **Compassos casando**: corte e emende música no tempo forte (grid = 60/BPM por batida; `analisar_audio.py musica` dá tom e subidas). Se precisar, mude a velocidade calculando o BPM.
- **Mesclar entre os Reels**: a música do gancho de um vira o final de outro, a do meio vira o começo de outro. Pode usar as músicas dos docs do Felipe (as dos docs são ~13 dB mais altas que as Class Act: compense o ganho).
- Labels: música Cerulean, risers Forest. Bin `10 ÁUDIO / <Leva> - Música e SFX`.

### 7. Legendas
O Premiere gera as legendas (pt-BR, 15 caracteres). O Bridge não lê nem move legendas: gere um **arquivo de ajustes** em `99. Temp/legendas_<reel>_ajustes.md` com tempo, texto revisado e posição, para ele aplicar. Padrão em `references/padrao.md` (gancho em caixa alta preta sobre caixa branca; tela dividida sobe pro meio).

### 8. Entregar
- Resumo por Reel: clipes, cobertura, o que veio de onde.
- **Lista do que é incerto** (minutagem, o que buscou, o que pôs no lugar). Ele prefere saber a descobrir.
- O que você não ouviu (toda a música) e se o projeto está salvo.

## Depois que ele finalizar
Se ele mexer na sua versão e pedir pra aprender, compare as duas (`dumpSeq` nas duas versões, mesma lógica da revisão da docs-felipe) e proponha lições. Grave em `references/aprendizado.md` só o que ele aprovar.
