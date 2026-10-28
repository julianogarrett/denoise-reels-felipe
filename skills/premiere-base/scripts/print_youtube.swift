// Gera um "print" de vídeo do YouTube (capa + duração + avatar + título + canal + views/data) em PNG.
// Uso: swift print_youtube.swift capa.jpg avatar.jpg "Título" "Canal" "1,2 mi de visualizações • há 4 anos" "12:34" saida.png
// Use só dados reais do vídeo (yt-dlp --dump-json). Nunca invente print de vídeo que não existe mais.
import AppKit
// args: thumb avatar title channel meta duration out
let a = CommandLine.arguments
let thumbP = a[1], avP = a[2], title = a[3], channel = a[4], meta = a[5], dur = a[6], out = a[7]
let pad = 48.0, W = 1700.0, tw = W - 2*pad, th = tw*9/16
let avS = 110.0, gap = 28.0
let titleFont = NSFont.systemFont(ofSize: 58, weight: .semibold)
let subFont = NSFont.systemFont(ofSize: 40, weight: .regular)
let textW = tw - avS - gap
let tAttr: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: NSColor(white: 0.95, alpha: 1)]
let tStr = NSAttributedString(string: title, attributes: tAttr)
let tRect = tStr.boundingRect(with: NSSize(width: textW, height: 400), options: [.usesLineFragmentOrigin])
let H = pad + th + 36 + ceil(tRect.height) + 14 + 48 + 48 + pad
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(W), pixelsHigh: Int(H), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState(); let g = NSGraphicsContext(bitmapImageRep: rep)!; NSGraphicsContext.current = g
g.imageInterpolation = .high
NSColor(calibratedRed: 0.059, green: 0.059, blue: 0.059, alpha: 1).setFill(); NSRect(x: 0, y: 0, width: W, height: H).fill()
// flipped helper: y from top
func R(_ x: Double, _ y: Double, _ w: Double, _ h: Double) -> NSRect { NSRect(x: x, y: H - y - h, width: w, height: h) }
let tr = R(pad, pad, tw, th)
if let img = NSImage(contentsOfFile: thumbP), let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) {
  NSGraphicsContext.saveGraphicsState(); NSBezierPath(roundedRect: tr, xRadius: 30, yRadius: 30).addClip()
  let iw = Double(cg.width), ih = Double(cg.height), sc = max(tw/iw, th/ih)
  NSImage(cgImage: cg, size: .zero).draw(in: NSRect(x: tr.midX - iw*sc/2, y: tr.midY - ih*sc/2, width: iw*sc, height: ih*sc))
  NSGraphicsContext.restoreGraphicsState()
}
// duration badge
let dAttr: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 34, weight: .semibold), .foregroundColor: NSColor.white]
let dStr = NSAttributedString(string: dur, attributes: dAttr); let ds = dStr.size()
let br = R(pad + tw - ds.width - 24 - 18, pad + th - ds.height - 10 - 18, ds.width + 24, ds.height + 10)
NSColor(white: 0, alpha: 0.8).setFill(); NSBezierPath(roundedRect: br, xRadius: 10, yRadius: 10).fill()
dStr.draw(at: NSPoint(x: br.minX + 12, y: br.minY + 5))
// avatar
let ty = pad + th + 36
let ar = R(pad, ty, avS, avS)
NSGraphicsContext.saveGraphicsState(); NSBezierPath(ovalIn: ar).addClip()
if let av = NSImage(contentsOfFile: avP) { av.draw(in: ar) } else { NSColor.gray.setFill(); ar.fill() }
NSGraphicsContext.restoreGraphicsState()
// title + subtitles
let tx = pad + avS + gap
tStr.draw(with: R(tx, ty - 4, textW, ceil(tRect.height) + 4), options: [.usesLineFragmentOrigin])
let sAttr: [NSAttributedString.Key: Any] = [.font: subFont, .foregroundColor: NSColor(white: 0.67, alpha: 1)]
var sy = ty + ceil(tRect.height) + 14
NSAttributedString(string: channel, attributes: sAttr).draw(at: NSPoint(x: tx, y: H - sy - 48)); sy += 50
NSAttributedString(string: meta, attributes: sAttr).draw(at: NSPoint(x: tx, y: H - sy - 48))
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
