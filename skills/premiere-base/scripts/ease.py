#!/usr/bin/env python3
"""Gera ease.json: a curva do "Smooth Caption Up" assada frame a frame.

O ExtendScript não ajusta alças de bezier, então gravamos um keyframe por frame
com o valor exato da curva (no render é idêntico a uma curva bezier).

Curva padrão (aprovada em 11/10/2026): velocidade começa em 0, pico rápido em
~20% da duração e desaceleração longa (influência 25% na saída, 85% na chegada).

uso: python3 ease.py [saida.json] [--fps 23.976] [--i1 0.25] [--i2 0.85]
"""
import json, sys, argparse

ap = argparse.ArgumentParser()
ap.add_argument('out', nargs='?', default='ease.json')
ap.add_argument('--fps', type=float, default=24000/1001)
ap.add_argument('--i1', type=float, default=0.25, help='influência de saída do 1º keyframe')
ap.add_argument('--i2', type=float, default=0.85, help='influência de chegada do 2º keyframe')
ap.add_argument('--t-fade', type=float, default=0.2667, help='duração de opacidade e blur (s)')
ap.add_argument('--t-move', type=float, default=0.5667, help='duração da subida (s)')
a = ap.parse_args()

def bez(P, t):
    B = lambda u, i: (1-u)**3*P[0][i] + 3*(1-u)**2*u*P[1][i] + 3*(1-u)*u**2*P[2][i] + u**3*P[3][i]
    lo, hi = 0.0, 1.0
    for _ in range(60):
        m = (lo+hi)/2
        if B(m, 0) < t: lo = m
        else: hi = m
    return B((lo+hi)/2, 1)

def curve(v0, v1, T):
    P = [(0, v0), (a.i1*T, v0), (T - a.i2*T, v1), (T, v1)]   # velocidade 0 nas duas pontas
    n = int(T * a.fps)
    ks = [(round(k/a.fps, 5), round(bez(P, k/a.fps), 5)) for k in range(n+1)]
    ks.append((round(T, 5), v1))
    return ks

E = {'op': curve(0, 100, a.t_fade),
     'bl': curve(35, 0, a.t_fade),
     'py': [[t, [0.5, v]] for t, v in curve(0.5776, 0.5, a.t_move)]}
json.dump(E, open(a.out, 'w'))
print('ok', a.out, 'opacidade:', [v for _, v in E['op']])
