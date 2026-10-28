import AppKit
let p = CommandLine.arguments[1], o = CommandLine.arguments[2]
let img = NSImage(contentsOfFile: p)!
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 960, pixelsHigh: 540, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSColor.black.setFill(); NSRect(x:0,y:0,width:960,height:540).fill(); img.draw(in: NSRect(x:0,y:0,width:960,height:540))
NSGraphicsContext.restoreGraphicsState(); try! rep.representation(using: .jpeg, properties: [:])!.write(to: URL(fileURLWithPath: o))
