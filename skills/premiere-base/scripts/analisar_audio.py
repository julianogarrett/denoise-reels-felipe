#!/usr/bin/env python3
"""Análise de áudio para a trilha e os SFX.

  python3 analisar_audio.py musica ARQ1.wav ARQ2.mp3 ...
      -> duração, TOM (Krumhansl) e SUBIDAS naturais (s, ganho em dB) de cada música.
  python3 analisar_audio.py sfx ARQ1.wav ...
      -> duração, início e PICO (s) de cada efeito. Posicione: início = corte − pico.
  python3 analisar_audio.py perfil ARQ.wav [inicio] [fim]
      -> volume (dB relativo) a cada 0,25 s, para escolher pontos de corte/remix.

Converte com `afconvert` (macOS) para WAV mono; sem dependências externas.
"""
import sys, os, subprocess, struct, math, tempfile, json

def to_wav(path, sr):
    t = tempfile.mktemp(suffix='.wav')
    subprocess.run(['afconvert', '-f', 'WAVE', '-d', f'LEI16@{sr}', '-c', '1', path, t], check=True, capture_output=True)
    b = open(t, 'rb').read(); os.remove(t); i = 12
    while i < len(b):
        cid = b[i:i+4]; sz = struct.unpack('<I', b[i+4:i+8])[0]
        if cid == b'data':
            d = b[i+8:i+8+sz]; return sr, struct.unpack('<%dh' % (len(d)//2), d[:len(d)//2*2])
        i += 8 + sz + (sz & 1)

def env(a, sr, win_s):
    win = max(1, int(sr * win_s))
    e = [math.sqrt(sum(x*x for x in a[k:k+win:2]) / (win/2)) + 1e-6 for k in range(0, len(a) - win, win)]
    mx = max(e); return [20 * math.log10(v / mx) for v in e]

def goertzel(x, sr, f):
    w = 2*math.pi*f/sr; c = 2*math.cos(w); s1 = s2 = 0.0
    for v in x: s0 = v + c*s1 - s2; s2 = s1; s1 = s0
    return s1*s1 + s2*s2 - c*s1*s2

MAJ = [6.35,2.23,3.48,2.33,4.38,4.09,2.52,5.19,2.39,3.66,2.29,2.88]; MIN = [6.33,2.68,3.52,5.38,2.60,3.53,2.54,4.75,3.98,2.69,3.34,3.17]
N = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B']
def corr(a, b):
    ma, mb = sum(a)/12, sum(b)/12
    return sum((x-ma)*(y-mb) for x, y in zip(a, b)) / math.sqrt(sum((x-ma)**2 for x in a) * sum((y-mb)**2 for y in b))
def key(a, sr):
    ch = [0]*12; step = max(1, len(a)//12)
    for k in range(12):
        seg = a[k*step:k*step + sr//2]
        if len(seg) < sr//4: continue
        for midi in range(36, 84): ch[midi % 12] += math.sqrt(goertzel(seg, sr, 440 * 2**((midi-69)/12)))
    return max([(corr(ch, MAJ[-i:]+MAJ[:-i]), N[i]) for i in range(12)] + [(corr(ch, MIN[-i:]+MIN[:-i]), N[i]+'m') for i in range(12)])[1]

def lifts(db):
    L = []
    for k in range(16, len(db) - 8):
        g = sum(db[k:k+8])/8 - sum(db[k-16:k])/16
        if g > 5: L.append((k*0.25, round(g, 1)))
    C = []
    for t, g in L:
        if C and t - C[-1][0] < 3:
            if g > C[-1][1]: C[-1] = (t, g)
        else: C.append((t, g))
    return [c for c in C if c[0] > 4.5]   # ignora a entrada do arquivo

mode, files = sys.argv[1], sys.argv[2:]
if mode == 'musica':
    for f in files:
        sr, a = to_wav(f, 8000)
        print(json.dumps({'arquivo': os.path.basename(f), 'dur': round(len(a)/sr, 2), 'tom': key(a, sr), 'subidas': lifts(env(a, sr, 0.25))}, ensure_ascii=False))
elif mode == 'sfx':
    for f in files:
        sr, a = to_wav(f, 4000); e = env(a, sr, 0.02); pk = e.index(max(e))
        on = next((k for k, v in enumerate(e) if v > -20), 0)
        print(f'{os.path.basename(f)[:45]:45s} dur={len(a)/sr:.2f}s inicio={on*0.02:.2f}s pico={pk*0.02:.2f}s')
elif mode == 'perfil':
    sr, a = to_wav(files[0], 4000); db = env(a, sr, 0.25)
    s = float(files[1]) if len(files) > 1 else 0; e = float(files[2]) if len(files) > 2 else len(db)/4
    print(' '.join(f'{k/4:.2f}:{int(db[k])}' for k in range(int(s*4), min(len(db), int(e*4)))))
