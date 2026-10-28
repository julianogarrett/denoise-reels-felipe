function dumpSeq(id,path){var ss=app.project.sequences,s=null;for(var i=0;i<ss.numSequences;i++)if(ss[i].sequenceID==id)s=ss[i];
var f=new File(path);f.encoding='UTF-8';f.open('w');
function pv(pr){try{if(pr.isTimeVarying()){var ks=pr.getKeys();var a=[];for(var k=0;k<ks.length&&k<4;k++){var v=pr.getValueAtKey(ks[k]);a.push(String(v));}return 'K'+ks.length+'['+a.join(';')+']';}return String(pr.getValue());}catch(e){return '?';}}
function info(c){var o=[];for(var k=0;k<c.components.numItems;k++){var cp=c.components[k];var mn=cp.matchName.replace('AE.ADBE ','');var x=mn;
 if(mn=='Motion'){var pp=[];for(var p=0;p<cp.properties.numItems;p++){var n=cp.properties[p].displayName;if(n=='Scale'||n=='Position'||n=='Anchor Point')pp.push(n.charAt(0)+'='+pv(cp.properties[p]));}x+='('+pp.join(',')+')';}
 if(mn=='Opacity'){x+='('+pv(cp.properties[0])+')';}
 if(mn=='Geometry'){var pp=[];for(var p=0;p<cp.properties.numItems;p++){var n=cp.properties[p].displayName;if(n=='Scale Height'||n=='Position'||n=='Opacity')pp.push(n.charAt(0)+'='+pv(cp.properties[p]));}x+='('+pp.join(',')+')';}
 if(cp.displayName=='Volume'){for(var p=0;p<cp.properties.numItems;p++)if(cp.properties[p].displayName=='Level')x='Vol('+pv(cp.properties[p])+')';}
 o.push(x);}return o.join(' ');}
for(var t=0;t<s.videoTracks.numTracks;t++){var tr=s.videoTracks[t];for(var i=0;i<tr.clips.numItems;i++){var c=tr.clips[i];var lbl='';try{lbl=c.projectItem?c.projectItem.getColorLabel():'';}catch(e){}
 f.write('V'+(t+1)+'\t'+c.start.seconds.toFixed(3)+'\t'+c.end.seconds.toFixed(3)+'\t'+c.inPoint.seconds.toFixed(3)+'\t'+(c.disabled?'OFF':'')+'\t'+c.name+'\t'+lbl+'\t'+info(c)+'\n');}}
for(var t=0;t<s.audioTracks.numTracks;t++){var tr=s.audioTracks[t];for(var i=0;i<tr.clips.numItems;i++){var c=tr.clips[i];
 f.write('A'+(t+1)+'\t'+c.start.seconds.toFixed(3)+'\t'+c.end.seconds.toFixed(3)+'\t'+c.inPoint.seconds.toFixed(3)+'\t'+(c.disabled?'OFF':'')+'\t'+c.name+'\t\t'+(t==0?'':info(c))+'\n');}}
var m=s.markers.getFirstMarker();while(m){f.write('M\t'+m.start.seconds.toFixed(3)+'\t'+m.end.seconds.toFixed(3)+'\t\t\t'+m.name+'\t\t'+m.comments+'\n');m=s.markers.getNextMarker(m);}
f.close();return s.name;}
