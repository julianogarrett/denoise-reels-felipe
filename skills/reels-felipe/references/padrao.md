# Padrão dos Reels do Felipe (números)

Sequência 1080×1920, 30 fps. Referência máxima de **performance**: o Reel do Mark Rober (mais de 1 milhão de views, `08. Agosto/shorts agosto.prproj`, Sequence 01, 142,27–240,27 s). Referência de **música**: o do Ryan Trahan e a Sequence 01 de agosto. Leva aprovada mais recente: `10. Outubro/Leva 02 - Reels Outubro (Renomear)`, sequência *Shorts Outubro*.

## Faixas (Shorts Outubro)
- V1: Felipe (decupagem do Juliano). Os punch-ins dele são um Transform ou uma Adjustment Layer de zoom (AutoCut): não mexa.
- V2: fundos da tela dividida (PNG da cor da borda da mídia).
- V3: mídias (fotos, trechos de vídeo, prints do YouTube).
- Acima: Graphics/cartelas.
- A1: voz. A2–A4: música e risers.

## Tela dividida (Shorts Outubro, aprovada)
- Mídia na metade de cima (y de 0 a 960 px). Felipe na metade de baixo, com **90% da escala**, rosto inteiro (o topo do cabelo encosta na divisão).
- Foto/vídeo: preenche a metade de cima; Crop Bottom pra não passar da divisão. Escala de still pra cobrir a metade de cima: 88,9 × w/h (em % do quadro).
- Mídia pequena/fundo liso: inteira, até 92% da largura, centralizada na metade de cima, sobre um PNG de fundo com a cor da borda dela.
- Vídeo antigo com tarja preta (ex.: Wolverine, 2:54): ficou pequeno sobre preto; pergunte se ele prefere preencher.

Variante antiga (Sidemen / Mark Rober de agosto): B-roll em cima (Position Y ≈ 0,24), Felipe embaixo (Y ≈ 0,70, ~(584, 1420) px), Color Matte branco com Crop Bottom 50 na V3. Use só se ele pedir esse visual.

## Gancho (0 a ~3,4 s)
Sempre tela dividida: Felipe embaixo e imagem **em movimento** em cima (no Mark Rober: o vídeo do YouTube dele, Position 0,5/0,24, Scale 94). Um print entra perto do fim do gancho com a animação padrão e um zoom leve (ex.: 206→221).

## Animação
- Entrada (Smooth Caption Up): Gaussian Blur 35→0 em 0,27 s (8 frames); Opacity 0→100 em 0,27 s; Position Y 0,5776→0,5 em 0,57 s (sobe ~150 px). Chegada com desaceleração forte.
- Ken Burns em tela cheia: escala +4–8% ao longo do clipe (205→217, 111→119, 100→104). Às vezes pan horizontal.
- B-roll lateral: Position X de fora (direita ou esquerda) para o centro, com ease.
- Cartelas: fundo Color Matte ou branco, vários textos entrando um após o outro com a animação padrão; final branco (no Mark Rober, 94,7–99,3 s).

## Música
Pastas: as Class Act (Piano, Brass, Violin Resonance, Reprise Strings 1/2) estão no projeto `08. Agosto/shorts agosto.prproj`; as dos docs em `Felipe/02. Vídeos/04. Docs/10. Outubro/Leva 01 - Diario de um CEO e Mark Rober/02. Brolls/00. Trilha (ref Johnny)/Musicas`. Tons conhecidos: Immaterial Am (mesmo tom das cordas), Story Unfolds Fm, Hidden Thread Cm, Potencial Dm, After the Bunker Dm, Subtle Truth Cm, Quantum Edge Fm.

**Sequence 01 de agosto (padrão que ele aprovou):**
- Gancho: Violin Resonance −12, Brass −12,3 ou Piano −14,6. Às vezes o Brass pula de in-point com um Riser Sword −21 no meio do gancho.
- Corpo: Piano −14,6 / Brass −12 caindo pra −21,7, crossfades de 0,2–4 s.
- Subida antes do clímax: −20 → −8,8 (ou −12 → −4,5).
- **Riser Sword** (pico em 1,70 s, ~−19) terminando no corte do clímax.
- Final: Class Act Reprise Strings 1 (e Strings 2 alinhada pelo mesmo offset do arquivo), ~−15/−17, até 1–3 s depois do fim.
- Às vezes: cordas fortes (−6,9) por ~6 s no impacto, ~9 s de silêncio e as cordas voltam baixas.
- Medido: música sob a voz ≈ −40 dBFS RMS; no gancho ≈ −30.

**Reel do Ryan Trahan (referência de música preferida):** gancho com Riser Super 01 (−7 dB) + string do logo Artlist (−7,6); trilha Monument (69,8 BPM, compasso de 3,44 s) entra logo após o gancho (−9 → −11); Riser Long 04 (−3/0) terminando ~0,2 s depois de cada impacto; edições no compasso; quase silêncio (−18) nas frases-chave; resolução com Whodunit (110 BPM) em fade até o fim da fala; CTA sem música.

**Mescla aplicada na Shorts Outubro (exemplo):**

| Reel | Gancho | Corpo / subida | Riser no clímax | Final |
|---|---|---|---|---|
| Colin & Samir | Violin Resonance | Piano → Brass | "Time 100 Creators" | cordas fortes, silêncio, cordas voltam |
| Hacksmith | Brass com pulo + Riser | Brass baixo → Piano | "milhões de inscritos" | cordas |
| Universo Narrado | Story Unfolds | Immaterial | "mais de 1 milhão" | cordas |
| Z2 | Piano | Violin Resonance | "surge a Z2" | Brass |
| Yes Theory | Hidden Thread | Potencial | "dez anos, 10 milhões" | cordas subindo até o fim |

## Legendas
- Geradas pelo Premiere: pt-BR, 15 caracteres, Inter-Bold, branco.
- **Gancho**: CAIXA ALTA, texto preto sobre caixa branca, maior, na linha da divisão (Y = 960 px / 50%).
- **Tela dividida**: estilo normal, sobe para o meio (Y = 960 px).
- Tela cheia: posição padrão.
- Exemplo de arquivo de ajustes: `Felipe/02. Vídeos/03. Shorts/10. Outubro/Leva 01 - Teste skill Sidemen/99. Temp/legendas_sidemen_ajustes.md`.
