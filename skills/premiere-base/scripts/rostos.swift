import AppKit
import Vision
let dir = CommandLine.arguments[1]
for f in try! FileManager.default.contentsOfDirectory(atPath: dir).sorted() where f.hasSuffix(".jpg") {
  let img = NSImage(contentsOfFile: dir+"/"+f)!; let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil)!
  let r = VNDetectFaceRectanglesRequest(); try? VNImageRequestHandler(cgImage: cg).perform([r])
  let s = (r.results ?? []).map{ String(format: "(%.3f,%.3f a=%.3f)", $0.boundingBox.midX, 1-$0.boundingBox.midY, $0.boundingBox.width*$0.boundingBox.height) }.joined(separator: " ")
  print(f, s)
}
