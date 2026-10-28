# deNoise · Reels do Felipe (skill para Claude Code)

Skill da **deNoise Studio** que edita os Reels/Shorts verticais do Felipe no **Adobe Premiere Pro** pelo Claude Code: B-roll com ~70% de cobertura, tela dividida, animação de entrada, sound design e lista de ajustes de legenda. Faz a parte mecânica (~70% da edição); o editor finaliza.

São duas skills que andam juntas:

| Skill | O que faz |
|---|---|
| `skills/reels-felipe` | O padrão dos Reels: fluxo, números exatos (`references/padrao.md`) e o que já foi aprovado ou corrigido (`references/aprendizado.md`) |
| `skills/premiere-base` | A base técnica: conectar no Premiere pelo MCP Bridge, ExtendScript, colocar clipes sem apagar vizinhos, keyframes com ease e os scripts (transcrição, dump da sequência, busca de imagens, print do YouTube, rostos, áudio) |

## Requisitos

- **macOS** (os scripts usam Swift/AppKit/Vision e `afconvert`)
- **Adobe Premiere Pro** 2020+ (testado no 26.5)
- **Claude Code** instalado e logado
- Xcode Command Line Tools (`swift`, `python3`), Node 20+, `yt-dlp` e `ffmpeg`: o `install.sh` cuida disso

## Instalar

```bash
git clone https://github.com/julianogarrett/denoise-reels-felipe.git ~/denoise-reels-felipe
cd ~/denoise-reels-felipe && ./install.sh
```

O script:
1. Liga as duas skills em `~/.claude/skills/` (link para o repo: `git pull` atualiza).
2. Põe `yt-dlp`, `ffmpeg` e `ffprobe` em `~/.local/bin` (via Homebrew se tiver; senão baixa os binários oficiais).
3. Cria `~/.config/yt-dlp/config` (H.264 + AAC em MP4) se não existir.
4. Instala o MCP Bridge do Premiere (`npm install -g adobe-premiere-pro-mcp`, `--install-cep`) e registra o servidor `premiere-pro` no Claude Code.

Depois, à mão:
1. Feche e abra o Premiere. **Window › Extensions › MCP Bridge (CEP)** → **Start Bridge**.
2. Instale a fonte **Inter** se não tiver.
3. Abra uma **sessão nova** do Claude Code e peça: `roda verify_premiere_connection, sem mudar nada`.

## Usar

Abra o projeto do Premiere com a sequência de Reels já decupada (V1/A1) e peça, por exemplo:

> Carrega as skills reels-felipe e premiere-base. Na sequência "Shorts Novembro", faz o B-roll dos 5 Reels. Pode rodar ExtendScript nesta sessão.

A skill trabalha em etapas (B-roll → tela dividida → música → legendas), faz backup da sequência antes de cada uma e para pra mostrar o resultado.

## O que NÃO está aqui (pegue com a deNoise)

- **Músicas e SFX licenciados** (Class Act Piano/Brass/Violin Resonance/Reprise Strings, Riser Sword, Risers, Impacts etc.). A skill cita os nomes e níveis; os arquivos ficam no projeto de referência e na pasta de assets do estúdio.
- **Projetos e brutos do cliente** (`shorts agosto.prproj`, levas de outubro). Os caminhos citados nas skills seguem a estrutura de pastas da deNoise (`00. Clientes/01. Ongoing/Felipe/...`).

## Regras que a skill segue

- V1/A1 são do editor: não mexe sem pedido explícito.
- Trabalha numa cópia da sequência e **não salva o projeto** sem pedir.
- Nunca apaga arquivo.
- **Sem banco de imagem e sem imagem de IA**: só material real da pessoa. Sem material, o trecho fica vazio e ela avisa.
- Não ouve áudio: sempre diz o que precisa ser conferido de ouvido.
