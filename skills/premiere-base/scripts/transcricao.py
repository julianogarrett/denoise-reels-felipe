#!/usr/bin/env python3
"""Extrai a transcrição que o Premiere guarda dentro do .prproj e mapeia cada
palavra para a minutagem da timeline.

1. Rode dump_sequencia.jsx na sequência e salve o .tsv (A1 = fala).
2. python3 transcricao.py PROJETO.prproj DUMP.tsv SAIDA_DIR

Gera em SAIDA_DIR:
  words.json  -> [[tempo_timeline, palavra_normalizada, palavra], ...]
  texto.txt   -> uma linha por corte: "mm:ss.ss texto"

Os blocos <TranscriptData> não dizem de qual mídia são; o script testa cada
bloco contra os cortes de cada mídia e escolhe o que tem mais palavras dentro
dos in/out (verifique lendo o texto.txt).
"""
import sys, re, gzip, base64, struct, json, unicodedata, os

prproj, dump, outd = sys.argv[1], sys.argv[2], sys.argv[3]
os.makedirs(outd, exist_ok=True)
TK = 254016000000.0
x = gzip.open(prproj).read().decode('utf-8', 'ignore')
blocks = []
for m in re.finditer(r'<TranscriptData Encoding="base64"[^>]*>([^<]*)<', x):
    b = base64.b64decode(m.group(1)); words = {}
    def rs(q):
        if q < 0 or q + 4 > len(b): return None
        ln = struct.unpack_from('<I', b, q)[0]
        if not (0 < ln < 40) or q + 4 + ln > len(b): return None
        try: w = b[q+4:q+4+ln].decode('utf-8')
        except Exception: return None
        if not w.isprintable() or ' ' in w: return None
        return w
    for p in range(0, len(b) - 24, 4):
        off = struct.unpack_from('<I', b, p)[0]
        if not (4 <= off < len(b)): continue
        st, du = struct.unpack_from('<qq', b, p + 8)
        if not (0 <= st < 20000 * TK and 0 < du < 5 * TK): continue
        w = rs(p + off)
        if w is None or w == 'pt-pt': continue
        words[round(st / TK, 3)] = (st / TK, du / TK, w)
    blocks.append(sorted(words.values()))

A1 = []
for l in open(dump, encoding='utf-8'):
    p = l.rstrip('\n').split('\t')
    if len(p) >= 6 and p[0] == 'A1':
        s, e, i = float(p[1]), float(p[2]), float(p[3]); A1.append((s, e, i, i + (e - s), p[5]))

media = sorted(set(c[4] for c in A1)); mapping = {}
for mname in media:
    cl = [c for c in A1 if c[4] == mname]; best = (-1, None)
    for bi, W in enumerate(blocks):
        n = sum(1 for w in W for c in cl if c[2] <= w[0] < c[3])
        if n > best[0]: best = (n, bi)
    mapping[mname] = best[1]
    print(f'{mname} -> bloco {best[1]} ({best[0]} palavras dentro dos cortes)')

norm = lambda w: ''.join(ch for ch in unicodedata.normalize('NFD', w.lower()) if ch.isalnum())
out = []; lines = []
for s, e, i, o, n in sorted(A1):
    ws = [w for w in blocks[mapping[n]] if i - 0.03 <= w[0] < o - 0.02] if mapping[n] is not None else []
    for w in ws: out.append((round(s + max(0, w[0] - i), 3), norm(w[2]), w[2]))
    lines.append(f'{int(s//60):02d}:{s%60:05.2f} ' + ' '.join(w[2] for w in ws))
json.dump(sorted(out), open(os.path.join(outd, 'words.json'), 'w'), ensure_ascii=False)
open(os.path.join(outd, 'texto.txt'), 'w').write('\n'.join(lines))
print('palavras:', len(out), '| cortes:', len(A1))
