// Biblioteca ExtendScript comum (premiere-base). Usada por docs-felipe, reels-felipe, timeline-bruno e fotos-produto-chz.
// Uso: defina `var SEQID='...'` antes de carregar, ou chame getSeqByName().
// Padrão de chamada pelo Bridge:  $.evalFile(LIB); $.evalFile(SCRIPT); return main();
// Strings com acento: use escapes á etc. (scripts lidos de arquivo perdem o UTF-8).

function T(s){var t=new Time();t.seconds=s;return t;}
function getSeq(){var ss=app.project.sequences;for(var i=0;i<ss.numSequences;i++)if(ss[i].sequenceID==SEQID)return ss[i];return null;}
function getSeqByName(n){var ss=app.project.sequences;for(var i=0;i<ss.numSequences;i++)if(ss[i].name==n)return ss[i];return null;}
function findItem(name,par){par=par||app.project.rootItem;for(var i=0;i<par.children.numItems;i++){var c=par.children[i];if(c.type==2){var r=findItem(name,c);if(r)return r;}else if(c.name==name)return c;}return null;}
function findBin(name,par){par=par||app.project.rootItem;for(var i=0;i<par.children.numItems;i++){var c=par.children[i];if(c.type==2){if(c.name==name)return c;var r=findBin(name,c);if(r)return r;}}return null;}
function ensureBin(parent,name){for(var i=0;i<parent.children.numItems;i++){var c=parent.children[i];if(c.type==2&&c.name==name)return c;}return parent.createBin(name);}
function clipAt(track,st){for(var i=0;i<track.clips.numItems;i++){if(Math.abs(track.clips[i].start.seconds-st)<0.03)return track.clips[i];}return null;}
// coloca item (opcionalmente com in-point) e ajusta o fim
// grade de frames: TODO início/fim de clipe deve cair num frame inteiro da sequência (senão sobra vão de fração de frame = "frame fantasma")
var TPS=254016000000;
function seqFR(){var s=(typeof SEQID!='undefined'&&SEQID)?getSeq():app.project.activeSequence;return Number(s.timebase);}
function snapTicks(sec){var fr=seqFR();return Math.round(sec*TPS/fr)*fr;}
function snap(sec){return snapTicks(sec)/TPS;}
function TT(ticks){var t=new Time();t.ticks=String(ticks);return t;}
// coloca item (opcionalmente com in-point) com início e fim encaixados no frame
function place(track,item,start,end,inPt){var st=snapTicks(start),en=snapTicks(end);if(en<=st)return null;var stS=st/TPS,enS=en/TPS;
 if(inPt!=null){item.setInPoint(inPt,4);item.setOutPoint(inPt+(enS-stS)+0.2,4);}track.overwriteClip(item,TT(st));if(inPt!=null){item.clearInPoint(4);item.clearOutPoint(4);}
 var c=clipAt(track,stS);if(c){c.end=TT(en);}return c;}
function comp(c,mn){for(var k=0;k<c.components.numItems;k++){if(c.components[k].matchName==mn||c.components[k].displayName==mn)return c.components[k];}return null;}
function prop(cp,name){for(var p=0;p<cp.properties.numItems;p++){if(cp.properties[p].displayName==name)return cp.properties[p];}return null;}
// keyframes relativos ao início do clipe: pairs=[[t,valor],...]
function kf(pr,c,pairs){pr.setTimeVarying(true);var base=c.inPoint.seconds;for(var i=0;i<pairs.length;i++){var t=base+pairs[i][0];pr.addKey(t);pr.setValueAtKey(t,pairs[i][1],true);}}
// substitui todos os keyframes (setTimeVarying(false) apaga os antigos)
function setKeys(pr,c,pairs){pr.setTimeVarying(false);kf(pr,c,pairs);}
// volume: x em "dB da escala da skill" (−15 = música padrão sob a voz)
function db(x){return x<=-59?0:Math.pow(10,(x-15)/20);}
function lvl(c,pairs){var L=prop(comp(c,'Volume'),'Level');if(pairs.length==1){L.setValue(db(pairs[0][1]),true);return;}var base=c.inPoint.seconds;var st=c.start.seconds;L.setTimeVarying(true);for(var i=0;i<pairs.length;i++){var t=base+(pairs[i][0]-st);L.addKey(t);L.setValueAtKey(t,db(pairs[i][1]),true);}}
// preset Smooth Caption Up (curva frame a frame de E = conteúdo de ease.json) em clipe com Blur+Transform
function applySmoothUp(c,E,qtrack){var gb=comp(c,'AE.ADBE Gaussian Blur 2'),g=comp(c,'AE.ADBE Geometry');
 if(gb){setKeys(prop(gb,'Blurriness'),c,E.bl);var r=prop(gb,'Repeat Edge Pixels');if(r)r.setValue(true,true);}
 if(g){setKeys(prop(g,'Opacity'),c,E.op);setKeys(prop(g,'Position'),c,E.py);}return !!(gb&&g);}
// adiciona Blur+Transform via QE no clipe que começa em st da faixa de vídeo idx
function addBlurTransform(idx,st){app.enableQE();var qt=qe.project.getActiveSequence().getVideoTrackAt(idx);
 var blur=qe.project.getVideoEffectByName('Gaussian Blur (Legacy)')||qe.project.getVideoEffectByName('Gaussian Blur');var tfx=qe.project.getVideoEffectByName('Transform');
 for(var j=0;j<qt.numItems;j++){var q=qt.getItemAt(j);if(q.type!='Empty'&&Math.abs(q.start.secs-st)<0.03){q.addVideoEffect(blur);q.addVideoEffect(tfx);return true;}}return false;}
// labels de cor: defina NO ITEM DO PROJETO ANTES de colocar na timeline (o clipe herda; depois não dá pra mudar por script)
var LABEL={voz:1,musica:2,logo:3,zoom:10,foto:4,cor:6,cartela:7,tonal:8,motion:11,preto:12,sfx:15};
