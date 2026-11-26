// Stellt das Hauptmotiv eines Fotos frei und setzt es mittig auf ein weißes Quadrat.
// Aufruf: freistellen <eingabe> <ausgabe.png> [kantenlaenge=1600] [fuellung=0.84] [schatten=0.0] [motive=alle]
// motive: "alle", "groesstes" oder eine Liste von Nummern wie "1,3" (die Nummern gibt das Programm aus)
import AppKit
import CoreImage
import Vision

let a = CommandLine.arguments
guard a.count >= 3 else { print("Aufruf: freistellen <eingabe> <ausgabe.png> [kante] [fuellung] [schatten]"); exit(2) }
let kante = a.count > 3 ? CGFloat(Double(a[3])!) : 1600
let fuellung = a.count > 4 ? CGFloat(Double(a[4])!) : 0.84
let schatten = a.count > 5 ? CGFloat(Double(a[5])!) : 0.0
let auswahl = a.count > 6 ? a[6] : "alle"

guard let bild = CIImage(contentsOf: URL(fileURLWithPath: a[1]), options: [.applyOrientationProperty: true]) else {
    print("Bild nicht lesbar"); exit(1)
}
let handler = VNImageRequestHandler(ciImage: bild)
let anfrage = VNGenerateForegroundInstanceMaskRequest()
try handler.perform([anfrage])
guard let fund = anfrage.results?.first else { print("kein Motiv gefunden"); exit(1) }
let ctx = CIContext()
// Fläche jedes einzelnen Motivs bestimmen, damit sich gezielt eines auswählen lässt
var flaechen: [(Int, Int)] = []
for nr in fund.allInstances {
    let m = CIImage(cvPixelBuffer: try fund.generateScaledMaskForImage(forInstances: IndexSet(integer: nr), from: handler))
    let kw = 200, kh = 200
    let klein = m.transformed(by: CGAffineTransform(scaleX: CGFloat(kw) / m.extent.width, y: CGFloat(kh) / m.extent.height))
    var b = [UInt8](repeating: 0, count: kw * kh * 4)
    ctx.render(klein, toBitmap: &b, rowBytes: kw * 4, bounds: CGRect(x: 0, y: 0, width: kw, height: kh), format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
    var n = 0, sx = 0, sy = 0
    for y in 0..<kh { for x in 0..<kw where b[(y * kw + x) * 4] > 127 { n += 1; sx += x; sy += y } }
    flaechen.append((nr, n))
    print("motiv \(nr): \(n * 100 / (kw * kh)) % der Fläche, Mitte bei \(n > 0 ? sx * 100 / n / kw : 0) % / \(n > 0 ? sy * 100 / n / kh : 0) % (von links / von oben)")
}
var gewaehlt = fund.allInstances
if auswahl == "groesstes", let g = flaechen.max(by: { $0.1 < $1.1 }) {
    gewaehlt = IndexSet(integer: g.0)
} else if auswahl != "alle" {
    gewaehlt = IndexSet(auswahl.split(separator: ",").compactMap { Int($0) })
}
let maske = CIImage(cvPixelBuffer: try fund.generateScaledMaskForImage(forInstances: gewaehlt, from: handler))

// Begrenzungsrahmen des Motivs aus der Maske lesen
let mw = Int(maske.extent.width), mh = Int(maske.extent.height)
var roh = [UInt8](repeating: 0, count: mw * mh * 4)
ctx.render(maske, toBitmap: &roh, rowBytes: mw * 4, bounds: maske.extent, format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
var x0 = mw, x1 = -1, y0 = mh, y1 = -1
for y in 0..<mh { for x in 0..<mw where roh[(y * mw + x) * 4] > 127 {
    if x < x0 { x0 = x }; if x > x1 { x1 = x }; if y < y0 { y0 = y }; if y > y1 { y1 = y }
} }
guard x1 >= 0 else { print("leere Maske"); exit(1) }
// Bitmap-Zeilen laufen von oben nach unten, Core Image von unten nach oben
let rahmen = CGRect(x: CGFloat(x0), y: CGFloat(mh - 1 - y1), width: CGFloat(x1 - x0 + 1), height: CGFloat(y1 - y0 + 1))
let rand = [x0, mh - 1 - y1, mw - 1 - x1, y0].map { $0 <= 2 }
print("motiv \(Int(rahmen.width))x\(Int(rahmen.height)) von \(mw)x\(mh), angeschnitten l/u/r/o: \(rand)")

let durchsichtig = CIImage(color: .clear).cropped(to: bild.extent)
let motiv = bild.applyingFilter("CIBlendWithMask", parameters: [kCIInputBackgroundImageKey: durchsichtig, kCIInputMaskImageKey: maske])
let faktor = kante * fuellung / max(rahmen.width, rahmen.height)
let verschiebung = CGAffineTransform(translationX: -rahmen.midX, y: -rahmen.midY)
    .concatenating(CGAffineTransform(scaleX: faktor, y: faktor))
    .concatenating(CGAffineTransform(translationX: kante / 2, y: kante / 2))
let platziert = motiv.transformed(by: verschiebung)
let flaeche = CGRect(x: 0, y: 0, width: kante, height: kante)
var ergebnis = CIImage(color: .white).cropped(to: flaeche)
if schatten > 0 {
    // weicher Bodenschatten: abgedunkelte, weichgezeichnete und leicht nach unten versetzte Silhouette
    let silhouette = platziert.applyingFilter("CIColorMatrix", parameters: [
        "inputRVector": CIVector(x: 0, y: 0, z: 0, w: 0), "inputGVector": CIVector(x: 0, y: 0, z: 0, w: 0),
        "inputBVector": CIVector(x: 0, y: 0, z: 0, w: 0), "inputAVector": CIVector(x: 0, y: 0, z: 0, w: schatten)])
        .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: kante * 0.018])
        .transformed(by: CGAffineTransform(translationX: 0, y: -kante * 0.012))
    ergebnis = silhouette.composited(over: ergebnis)
}
ergebnis = platziert.composited(over: ergebnis).cropped(to: flaeche)
try ctx.writePNGRepresentation(of: ergebnis, to: URL(fileURLWithPath: a[2]), format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
