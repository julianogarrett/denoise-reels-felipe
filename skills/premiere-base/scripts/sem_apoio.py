#!/usr/bin/env python3
"""Lista os trechos em que só o apresentador aparece (nada de V4 pra cima).

Uso: python3 sem_apoio.py DUMP.tsv [--limite 10] [--words words.json]

Cada trecho acima do limite precisa de apoio (imagem, texto ou motion).
Com --words, mostra a fala do trecho para escolher o que ilustrar.
"""
import argparse, csv, json

ap = argparse.ArgumentParser()
ap.add_argument('dump')
ap.add_argument('--limite', type=float, default=10)
ap.add_argument('--words')
a = ap.parse_args()

apoio, fim = [], 0.0
for r in csv.reader(open(a.dump), delimiter='\t'):
    if not r or not r[0].startswith('V'):
        continue
    ini, fi = float(r[1]), float(r[2])
    if r[0] == 'V1':
        fim = max(fim, fi)
    elif int(r[0][1:]) >= 4:
        apoio.append((ini, fi))

apoio.sort()
blocos = []
for ini, fi in apoio:
    if blocos and ini <= blocos[-1][1] + 0.05:
        blocos[-1][1] = max(blocos[-1][1], fi)
    else:
        blocos.append([ini, fi])

trechos, p = [], 0.0
for ini, fi in blocos:
    trechos.append((p, ini))
    p = max(p, fi)
trechos.append((p, fim))
longos = [(i, f) for i, f in trechos if f - i > a.limite]

words = json.load(open(a.words)) if a.words else []
mmss = lambda s: '%d:%04.1f' % (s // 60, s % 60)
coberto = sum(f - i for i, f in blocos)
print('cobertura: %.1f%% | trechos > %gs sem apoio: %d | maior: %.0fs'
      % (100 * coberto / fim if fim else 0, a.limite, len(longos),
         max((f - i for i, f in trechos), default=0)))
for i, f in longos:
    print('\n%s – %s (%.0fs)' % (mmss(i), mmss(f), f - i))
    if words:
        print('  ' + ' '.join(w[2] for w in words if i <= w[0] < f))
