# Busca imagens no Bing (sem chave). Uso: python3 -I busca_imagens.py "termo" → URL | título
# Baixe com curl para a pasta da leva, nunca rode nada baixado.
import re,html,json,sys,urllib.request,urllib.parse
def search(q,n=15,extra='+filterui:imagesize-large'):
    u='https://www.bing.com/images/async?q='+urllib.parse.quote(q)+'&first=0&count=40&mmasync=1&setlang=en&cc=US&qft='+urllib.parse.quote(extra)
    r=urllib.request.Request(u,headers={'User-Agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15','Accept-Language':'en-US,en;q=0.9','Cookie':'SRCHHPGUSR=ADLT=OFF'})
    x=urllib.request.urlopen(r,timeout=20).read().decode('utf-8','ignore')
    out=[]
    for m in re.finditer(r'class="iusc"[^>]*?\bm="([^"]+)"',x):
        d=json.loads(html.unescape(m.group(1))); out.append((d.get('murl'),d.get('t','')))
    return out[:n]
if __name__=='__main__':
    for u,t in search(sys.argv[1]): print(u[:110],'|',t[:60])
