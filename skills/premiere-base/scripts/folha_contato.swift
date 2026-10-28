import AppKit
import Vision
let dir = CommandLine.arguments[1], out = CommandLine.arguments[2]
let files = try! FileManager.default.contentsOfDirectory(atPath: dir).filter{$0.hasSuffix(".jpg")}.sorted()
var faces: [String: [[Double]]] = [:]
let cols = 6, tw = 300, th = 200, lab = 26, per = 30
var sheet = 0
for chunk in stride(from: 0, to: files.count, by: per) {
  let sub = Array(files[chunk..<min(chunk+per, files.count)])
  let rows = (sub.count + cols - 1)/cols
  let W = cols*tw, H = rows*(th+lab)
  let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
  NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
  NSColor.darkGray.setFill(); NSRect(x:0,y:0,width:W,height:H).fill()
  for (i,f) in sub.enumerated() {
    let path = dir + "/" + f
    guard let img = NSImage(contentsOfFile: path), let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { continue }
    let req = VNDetectFaceRectanglesRequest()
    try? VNImageRequestHandler(cgImage: cg).perform([req])
    faces[f] = (req.results ?? []).map{ [ $0.boundingBox.midX, 1-$0.boundingBox.midY, $0.boundingBox.width*$0.boundingBox.height ] }
    let c = i % cols, r = i / cols
    let x = c*tw, y = H - (r+1)*(th+lab)
    let iw = Double(cg.width), ih = Double(cg.height), sc = min(Double(tw)/iw, Double(th)/ih)
    let dw = iw*sc, dh = ih*sc
    img.draw(in: NSRect(x: Double(x)+(Double(tw)-dw)/2, y: Double(y+lab)+(Double(th)-dh)/2, width: dw, height: dh))
    NSAttributedString(string: String(f.prefix(34)), attributes: [.font: NSFont.systemFont(ofSize: 15), .foregroundColor: NSColor.white]).draw(at: NSPoint(x: x+3, y: y+4))
  }
  NSGraphicsContext.restoreGraphicsState()
  try! rep.representation(using: .jpeg, properties: [.compressionFactor: 0.7])!.write(to: URL(fileURLWithPath: "\(out)/sheet\(sheet).jpg"))
  sheet += 1
}
let d = try! JSONSerialization.data(withJSONObject: faces)
try! d.write(to: URL(fileURLWithPath: "\(out)/faces.json"))
print("sheets", sheet)
