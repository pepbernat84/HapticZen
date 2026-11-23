#!/usr/bin/env swift

import AppKit
import CoreGraphics
import Foundation

struct SizeSpec {
    let folderName: String
    let width: Int
    let height: Int
}

struct ScreenCopy {
    let filename: String
    let headline: String
    let subtitle: String
}

struct LocalizedCopy {
    let lang: String
    let screens: [ScreenCopy]
    let canvasBadge: String
    let canvasHint: String
    let breathingPatternTitle: String
    let breathingPhase: String
    let breathingTouchHint: String
    let freePackTitle: String
    let mechPackTitle: String
    let naturePackTitle: String
    let textures: [(icon: String, name: String, unlocked: Bool, selected: Bool)]
    let widgetCalmToday: String
    let widgetBreathingBtn: String
    let widgetTexturesBtn: String
    let widgetLockTitle: String
}

let sizeSpecs = [
    SizeSpec(folderName: "6.7_1290x2796", width: 1290, height: 2796),
    SizeSpec(folderName: "6.5_1284x2778", width: 1284, height: 2778)
]

let localizations: [LocalizedCopy] = [
    LocalizedCopy(
        lang: "ca",
        screens: [
            ScreenCopy(
                filename: "01_canvas.png",
                headline: "Sent la calma\na cada gest",
                subtitle: "Textures Core Haptics d'alta precisió i àudio espacial ASMR."
            ),
            ScreenCopy(
                filename: "02_breathing.png",
                headline: "Respira amb\nguia hàptica",
                subtitle: "Tanca els ulls i segueix el ritme tàctil de cada inhalació."
            ),
            ScreenCopy(
                filename: "03_textures.png",
                headline: "Sis textures\nper explorar",
                subtitle: "Des de bambolles i sorra cinètica fins a engranatges i pluja."
            ),
            ScreenCopy(
                filename: "04_widgets.png",
                headline: "Widgets i\nApple Health",
                subtitle: "Objectiu diari, ratxa activa i minuts de calma al dia."
            )
        ],
        canvasBadge: "Bambolles de plàstic",
        canvasHint: "3 dits per obrir el menú",
        breathingPatternTitle: "Calma 4-2-6-2",
        breathingPhase: "Inhala",
        breathingTouchHint: "Sent el pols del ritme",
        freePackTitle: "Col·lecció Inicial",
        mechPackTitle: "Paquet Mecànic",
        naturePackTitle: "Paquet Natural",
        textures: [
            ("circle.grid.2x2.fill", "Bambolles", true, true),
            ("wind", "Sorra cinètica", true, false),
            ("keyboard.fill", "Màquina d'escriure", true, false),
            ("gearshape.2.fill", "Engranatges", true, false),
            ("cloud.heavyrain.fill", "Pluja intensa", false, false),
            ("snowflake", "Neu fresca", false, false)
        ],
        widgetCalmToday: "Calma d'avui",
        widgetBreathingBtn: "Respirar",
        widgetTexturesBtn: "Textures",
        widgetLockTitle: "Pantalla d'inici i bloqueig"
    ),
    LocalizedCopy(
        lang: "es",
        screens: [
            ScreenCopy(
                filename: "01_canvas.png",
                headline: "Siente la calma\nen cada gesto",
                subtitle: "Texturas Core Haptics de precisión y audio espacial ASMR."
            ),
            ScreenCopy(
                filename: "02_breathing.png",
                headline: "Respira con\nguía háptica",
                subtitle: "Cierra los ojos y sigue el pulso táctil de cada inhalación."
            ),
            ScreenCopy(
                filename: "03_textures.png",
                headline: "Seis texturas\npara explorar",
                subtitle: "Desde burbujas y arena cinética hasta engranajes y lluvia."
            ),
            ScreenCopy(
                filename: "04_widgets.png",
                headline: "Widgets y\nApple Health",
                subtitle: "Objetivo diario, racha activa y minutos de mindfulness."
            )
        ],
        canvasBadge: "Papel de burbujas",
        canvasHint: "3 dedos para abrir el menú",
        breathingPatternTitle: "Calma 4-2-6-2",
        breathingPhase: "Inhala",
        breathingTouchHint: "Siente el pulso del ritmo",
        freePackTitle: "Colección Inicial",
        mechPackTitle: "Paquete Mecánico",
        naturePackTitle: "Paquete Naturaleza",
        textures: [
            ("circle.grid.2x2.fill", "Burbujas", true, true),
            ("wind", "Arena cinética", true, false),
            ("keyboard.fill", "Máquina escribir", true, false),
            ("gearshape.2.fill", "Engranajes", true, false),
            ("cloud.heavyrain.fill", "Lluvia intensa", false, false),
            ("snowflake", "Nieve fresca", false, false)
        ],
        widgetCalmToday: "Calma de hoy",
        widgetBreathingBtn: "Respirar",
        widgetTexturesBtn: "Texturas",
        widgetLockTitle: "Pantalla de inicio y bloqueo"
    ),
    LocalizedCopy(
        lang: "en",
        screens: [
            ScreenCopy(
                filename: "01_canvas.png",
                headline: "Feel calm in\nevery touch",
                subtitle: "Precision Core Haptics textures paired with spatial ASMR."
            ),
            ScreenCopy(
                filename: "02_breathing.png",
                headline: "Haptic-guided\nbreathing",
                subtitle: "Close your eyes and follow the tactile pulse of every breath."
            ),
            ScreenCopy(
                filename: "03_textures.png",
                headline: "Six textures\nto explore",
                subtitle: "From bubble wrap and kinetic sand to gears and heavy rain."
            ),
            ScreenCopy(
                filename: "04_widgets.png",
                headline: "Widgets &\nApple Health",
                subtitle: "Track your daily goal, active streak, and Mindful Minutes."
            )
        ],
        canvasBadge: "Bubble Wrap",
        canvasHint: "Tap with 3 fingers for menu",
        breathingPatternTitle: "Paced 4-2-6-2",
        breathingPhase: "Inhale",
        breathingTouchHint: "Feel the tactile pulse",
        freePackTitle: "Starter Pack",
        mechPackTitle: "Mechanical Pack",
        naturePackTitle: "Nature Pack",
        textures: [
            ("circle.grid.2x2.fill", "Bubble Wrap", true, true),
            ("wind", "Kinetic Sand", true, false),
            ("keyboard.fill", "Typewriter", true, false),
            ("gearshape.2.fill", "Gears", true, false),
            ("cloud.heavyrain.fill", "Heavy Rain", false, false),
            ("snowflake", "Stepping Snow", false, false)
        ],
        widgetCalmToday: "Calm Today",
        widgetBreathingBtn: "Breathe",
        widgetTexturesBtn: "Textures",
        widgetLockTitle: "Home & Lock Screen"
    )
]

// MARK: - Colors & Geometry Helpers
let zenDark = NSColor(calibratedRed: 0.04, green: 0.05, blue: 0.08, alpha: 1.0)
let zenCard = NSColor(calibratedRed: 0.10, green: 0.12, blue: 0.18, alpha: 0.94)
let zenGlow = NSColor(calibratedRed: 0.35, green: 0.65, blue: 0.95, alpha: 1.0)
let zenAccent = NSColor(calibratedRed: 0.25, green: 0.50, blue: 0.85, alpha: 1.0)
let zenMuted = NSColor(calibratedWhite: 1.0, alpha: 0.68)

func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, canvasH: CGFloat) -> NSRect {
    NSRect(x: x, y: canvasH - y - h, width: w, height: h)
}

func pt(_ x: CGFloat, _ y: CGFloat, canvasH: CGFloat) -> NSPoint {
    NSPoint(x: x, y: canvasH - y)
}

func roundedFont(size: CGFloat, weight: NSFont.Weight) -> NSFont {
    let base = NSFont.systemFont(ofSize: size, weight: weight)
    if let desc = base.fontDescriptor.withDesign(.rounded), let rounded = NSFont(descriptor: desc, size: size) {
        return rounded
    }
    return base
}

func monoFont(size: CGFloat, weight: NSFont.Weight) -> NSFont {
    NSFont.monospacedDigitSystemFont(ofSize: size, weight: weight)
}

func drawText(_ text: String, in frame: NSRect, font: NSFont, color: NSColor, alignment: NSTextAlignment = .center) {
    let style = NSMutableParagraphStyle()
    style.alignment = alignment
    style.lineSpacing = 6
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: style
    ]
    NSAttributedString(string: text, attributes: attrs).draw(in: frame)
}

func drawSymbol(_ name: String, in frame: NSRect, color: NSColor, pointSize: CGFloat, weight: NSFont.Weight = .semibold) {
    let cfg = NSImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
    guard let baseImage = NSImage(systemSymbolName: name, accessibilityDescription: nil)?.withSymbolConfiguration(cfg) else {
        return
    }
    let tinted = NSImage(size: frame.size, flipped: false) { drawRect in
        color.set()
        baseImage.draw(in: drawRect)
        drawRect.fill(using: .sourceIn)
        return true
    }
    tinted.draw(in: frame)
}

func drawRadialGlow(centerX: CGFloat, centerYTop: CGFloat, radius: CGFloat, innerColor: NSColor, canvasH: CGFloat) {
    guard let ctx = NSGraphicsContext.current?.cgContext else { return }
    let space = CGColorSpaceCreateDeviceRGB()
    let colors = [innerColor.cgColor, innerColor.withAlphaComponent(0.0).cgColor] as CFArray
    guard let grad = CGGradient(colorsSpace: space, colors: colors, locations: [0.0, 1.0]) else { return }
    let center = pt(centerX, centerYTop, canvasH: canvasH)
    ctx.drawRadialGradient(grad, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: [])
}

func drawPill(frame: NSRect, fill: NSColor, stroke: NSColor, lineWidth: CGFloat = 2, radius: CGFloat? = nil) {
    let path = NSBezierPath(roundedRect: frame, xRadius: radius ?? frame.height / 2, yRadius: radius ?? frame.height / 2)
    fill.setFill()
    path.fill()
    stroke.setStroke()
    path.lineWidth = lineWidth
    path.stroke()
}

// MARK: - Device Frame & Screen Contents
func drawScreenshot(spec: SizeSpec, loc: LocalizedCopy, screenIndex: Int, outURL: URL) throws {
    let w = CGFloat(spec.width)
    let h = CGFloat(spec.height)

    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: spec.width,
        pixelsHigh: spec.height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ), let ctx = NSGraphicsContext(bitmapImageRep: rep) else {
        fatalError("Failed to create bitmap context")
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = ctx

    // 1. Background + top ambient glow
    zenDark.setFill()
    NSRect(x: 0, y: 0, width: w, height: h).fill()
    drawRadialGlow(centerX: w * 0.5, centerYTop: 220, radius: w * 0.85, innerColor: zenGlow.withAlphaComponent(0.24), canvasH: h)
    drawRadialGlow(centerX: w * 0.5, centerYTop: h * 0.65, radius: w * 0.9, innerColor: zenAccent.withAlphaComponent(0.14), canvasH: h)

    // 2. Promotional Copy
    let screen = loc.screens[screenIndex]
    drawText(
        screen.headline,
        in: rect(80, 130, w - 160, 260, canvasH: h),
        font: roundedFont(size: 88, weight: .bold),
        color: .white,
        alignment: .center
    )
    drawText(
        screen.subtitle,
        in: rect(110, 395, w - 220, 140, canvasH: h),
        font: roundedFont(size: 40, weight: .regular),
        color: zenMuted,
        alignment: .center
    )

    // 3. iPhone Mockup Frame
    let phoneX: CGFloat = 120
    let phoneY: CGFloat = 570
    let phoneW = w - 240
    let phoneH = h - 670
    let bezelRect = rect(phoneX, phoneY, phoneW, phoneH, canvasH: h)
    let bezelPath = NSBezierPath(roundedRect: bezelRect, xRadius: 118, yRadius: 118)
    NSColor(calibratedRed: 0.08, green: 0.09, blue: 0.13, alpha: 1.0).setFill()
    bezelPath.fill()
    NSColor(calibratedWhite: 1.0, alpha: 0.22).setStroke()
    bezelPath.lineWidth = 6
    bezelPath.stroke()

    let inset: CGFloat = 24
    let screenX = phoneX + inset
    let screenY = phoneY + inset
    let screenW = phoneW - inset * 2
    let screenH = phoneH - inset * 2
    let innerRect = rect(screenX, screenY, screenW, screenH, canvasH: h)
    let innerPath = NSBezierPath(roundedRect: innerRect, xRadius: 96, yRadius: 96)

    ctx.saveGraphicsState()
    innerPath.addClip()

    zenDark.setFill()
    innerRect.fill()

    // Dynamic Island
    let islandW: CGFloat = 260
    let islandH: CGFloat = 68
    let islandRect = rect(screenX + (screenW - islandW) / 2, screenY + 32, islandW, islandH, canvasH: h)
    drawPill(frame: islandRect, fill: .black, stroke: NSColor.white.withAlphaComponent(0.08), lineWidth: 1.5)

    // Status bar time
    drawText(
        "9:41",
        in: rect(screenX + 54, screenY + 46, 130, 44, canvasH: h),
        font: roundedFont(size: 32, weight: .semibold),
        color: .white,
        alignment: .left
    )

    switch screenIndex {
    case 0:
        drawCanvasScreen(screenX: screenX, screenY: screenY, screenW: screenW, screenH: screenH, canvasH: h, loc: loc)
    case 1:
        drawBreathingScreen(screenX: screenX, screenY: screenY, screenW: screenW, screenH: screenH, canvasH: h, loc: loc)
    case 2:
        drawTexturesScreen(screenX: screenX, screenY: screenY, screenW: screenW, screenH: screenH, canvasH: h, loc: loc)
    default:
        drawWidgetsScreen(screenX: screenX, screenY: screenY, screenW: screenW, screenH: screenH, canvasH: h, loc: loc)
    }

    // Home indicator bar
    let homeW: CGFloat = 320
    let homeRect = rect(screenX + (screenW - homeW) / 2, screenY + screenH - 36, homeW, 11, canvasH: h)
    drawPill(frame: homeRect, fill: NSColor.white.withAlphaComponent(0.35), stroke: .clear, lineWidth: 0)

    ctx.restoreGraphicsState()
    NSGraphicsContext.restoreGraphicsState()

    guard let pngData = rep.representation(using: .png, properties: [:]) else {
        fatalError("Failed to encode PNG")
    }
    try pngData.write(to: outURL)
}

func drawCanvasScreen(screenX: CGFloat, screenY: CGFloat, screenW: CGFloat, screenH: CGFloat, canvasH: CGFloat, loc: LocalizedCopy) {
    let cx = screenX + screenW * 0.5
    let cy = screenY + screenH * 0.48
    drawRadialGlow(centerX: cx, centerYTop: cy, radius: 480, innerColor: zenGlow.withAlphaComponent(0.30), canvasH: canvasH)

    // Concentric tactile ripples along drag arc
    let rippleSpots: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
        (-180, 170, 90, 0.30),
        (-95, 50, 130, 0.45),
        (10, -70, 170, 0.65),
        (140, -190, 210, 0.85)
    ]
    for (dx, dy, r, alpha) in rippleSpots {
        let rx = cx + dx
        let ry = cy + dy
        let circleRect = rect(rx - r, ry - r, r * 2, r * 2, canvasH: canvasH)
        let circlePath = NSBezierPath(ovalIn: circleRect)
        zenGlow.withAlphaComponent(alpha).setStroke()
        circlePath.lineWidth = 4
        circlePath.stroke()
    }

    // Luminous finger trail path
    let trail = NSBezierPath()
    trail.move(to: pt(cx - 210, cy + 210, canvasH: canvasH))
    trail.curve(
        to: pt(cx + 140, cy - 190, canvasH: canvasH),
        controlPoint1: pt(cx - 120, cy + 30, canvasH: canvasH),
        controlPoint2: pt(cx + 30, cy - 120, canvasH: canvasH)
    )
    trail.lineCapStyle = .round
    zenGlow.withAlphaComponent(0.55).setStroke()
    trail.lineWidth = 18
    trail.stroke()

    let fingerCenterX = cx + 140
    let fingerCenterY = cy - 190
    drawRadialGlow(centerX: fingerCenterX, centerYTop: fingerCenterY, radius: 130, innerColor: zenGlow.withAlphaComponent(0.85), canvasH: canvasH)
    let coreRect = rect(fingerCenterX - 24, fingerCenterY - 24, 48, 48, canvasH: canvasH)
    NSColor.white.setFill()
    NSBezierPath(ovalIn: coreRect).fill()

    // Active texture pill & subtle gesture hint
    let badgeW: CGFloat = 460
    drawPill(
        frame: rect(cx - badgeW / 2, screenY + 150, badgeW, 74, canvasH: canvasH),
        fill: zenCard,
        stroke: zenGlow.withAlphaComponent(0.45),
        lineWidth: 2
    )
    drawSymbol("circle.grid.2x2.fill", in: rect(cx - badgeW / 2 + 28, screenY + 168, 38, 38, canvasH: canvasH), color: zenGlow, pointSize: 30)
    drawText(
        loc.canvasBadge,
        in: rect(cx - badgeW / 2 + 78, screenY + 166, badgeW - 100, 44, canvasH: canvasH),
        font: roundedFont(size: 31, weight: .semibold),
        color: .white,
        alignment: .left
    )

    drawText(
        loc.canvasHint,
        in: rect(screenX + 60, screenY + screenH - 135, screenW - 120, 44, canvasH: canvasH),
        font: roundedFont(size: 28, weight: .medium),
        color: zenMuted,
        alignment: .center
    )
}

func drawBreathingScreen(screenX: CGFloat, screenY: CGFloat, screenW: CGFloat, screenH: CGFloat, canvasH: CGFloat, loc: LocalizedCopy) {
    let cx = screenX + screenW * 0.5
    let cy = screenY + screenH * 0.50

    // Header: pattern pill + timer pill
    let patternW: CGFloat = 330
    drawPill(
        frame: rect(screenX + 54, screenY + 148, patternW, 68, canvasH: canvasH),
        fill: zenCard,
        stroke: NSColor.white.withAlphaComponent(0.16),
        lineWidth: 2
    )
    drawSymbol("wind", in: rect(screenX + 78, screenY + 165, 34, 34, canvasH: canvasH), color: zenGlow, pointSize: 26)
    drawText(
        loc.breathingPatternTitle,
        in: rect(screenX + 122, screenY + 163, 240, 40, canvasH: canvasH),
        font: roundedFont(size: 27, weight: .semibold),
        color: .white,
        alignment: .left
    )

    let timerW: CGFloat = 230
    drawPill(
        frame: rect(screenX + screenW - 54 - timerW, screenY + 148, timerW, 68, canvasH: canvasH),
        fill: zenCard,
        stroke: NSColor.white.withAlphaComponent(0.16),
        lineWidth: 2
    )
    drawSymbol("heart.text.square.fill", in: rect(screenX + screenW - 54 - timerW + 24, screenY + 165, 34, 34, canvasH: canvasH), color: zenGlow, pointSize: 26)
    drawText(
        "02:40",
        in: rect(screenX + screenW - 54 - timerW + 70, screenY + 163, 140, 40, canvasH: canvasH),
        font: monoFont(size: 28, weight: .semibold),
        color: .white,
        alignment: .left
    )

    // Breathing glow + concentric rings + main orb
    drawRadialGlow(centerX: cx, centerYTop: cy, radius: 520, innerColor: zenGlow.withAlphaComponent(0.38), canvasH: canvasH)
    for i in 0..<3 {
        let r: CGFloat = 260 + CGFloat(i) * 76
        let ringRect = rect(cx - r, cy - r, r * 2, r * 2, canvasH: canvasH)
        let ring = NSBezierPath(ovalIn: ringRect)
        zenGlow.withAlphaComponent(0.32 - CGFloat(i) * 0.08).setStroke()
        ring.lineWidth = 4
        ring.stroke()
    }

    let orbR: CGFloat = 215
    let orbRect = rect(cx - orbR, cy - orbR, orbR * 2, orbR * 2, canvasH: canvasH)
    let orbPath = NSBezierPath(ovalIn: orbRect)
    if let ctx = NSGraphicsContext.current?.cgContext,
       let grad = CGGradient(
           colorsSpace: CGColorSpaceCreateDeviceRGB(),
           colors: [zenGlow.withAlphaComponent(0.92).cgColor, zenAccent.withAlphaComponent(0.45).cgColor] as CFArray,
           locations: [0.0, 1.0]
       ) {
        ctx.saveGState()
        orbPath.addClip()
        ctx.drawLinearGradient(
            grad,
            start: pt(cx - orbR, cy - orbR, canvasH: canvasH),
            end: pt(cx + orbR, cy + orbR, canvasH: canvasH),
            options: []
        )
        ctx.restoreGState()
    }

    drawText(
        loc.breathingPhase,
        in: rect(cx - 180, cy - 54, 360, 74, canvasH: canvasH),
        font: roundedFont(size: 56, weight: .bold),
        color: .white,
        alignment: .center
    )
    drawText(
        loc.breathingTouchHint,
        in: rect(cx - 190, cy + 28, 380, 44, canvasH: canvasH),
        font: roundedFont(size: 26, weight: .medium),
        color: NSColor.white.withAlphaComponent(0.86),
        alignment: .center
    )
}

func drawTexturesScreen(screenX: CGFloat, screenY: CGFloat, screenW: CGFloat, screenH: CGFloat, canvasH: CGFloat, loc: LocalizedCopy) {
    let pad: CGFloat = 46
    var cursorY = screenY + 148

    // Simulated sheet header
    drawText(
        "Haptic Zen",
        in: rect(screenX + pad, cursorY, screenW - pad * 2, 54, canvasH: canvasH),
        font: roundedFont(size: 38, weight: .bold),
        color: .white,
        alignment: .center
    )
    cursorY += 84

    // Pack groups + 2-column grid cards
    let groups: [(String, ArraySlice<(icon: String, name: String, unlocked: Bool, selected: Bool)>)] = [
        (loc.freePackTitle, loc.textures[0..<2]),
        (loc.mechPackTitle, loc.textures[2..<4]),
        (loc.naturePackTitle, loc.textures[4..<6])
    ]

    let cardGap: CGFloat = 24
    let cardW = (screenW - pad * 2 - cardGap) / 2
    let cardH: CGFloat = 265

    for (title, items) in groups {
        drawText(
            title,
            in: rect(screenX + pad, cursorY, screenW - pad * 2, 46, canvasH: canvasH),
            font: roundedFont(size: 32, weight: .bold),
            color: .white,
            alignment: .left
        )
        cursorY += 58

        for (col, item) in items.enumerated() {
            let x = screenX + pad + CGFloat(col) * (cardW + cardGap)
            let cardRect = rect(x, cursorY, cardW, cardH, canvasH: canvasH)
            let fill = item.selected ? zenGlow.withAlphaComponent(0.20) : zenCard
            let stroke = item.selected ? zenGlow : NSColor.white.withAlphaComponent(0.12)
            drawPill(frame: cardRect, fill: fill, stroke: stroke, lineWidth: item.selected ? 4 : 2, radius: 34)

            drawSymbol(
                item.icon,
                in: rect(x + 28, cursorY + 30, 56, 56, canvasH: canvasH),
                color: item.selected ? zenGlow : .white,
                pointSize: 42
            )

            if item.selected {
                drawSymbol("checkmark.circle.fill", in: rect(x + cardW - 68, cursorY + 32, 40, 40, canvasH: canvasH), color: zenGlow, pointSize: 32)
            } else if !item.unlocked {
                drawSymbol("lock.fill", in: rect(x + cardW - 64, cursorY + 34, 34, 34, canvasH: canvasH), color: zenMuted, pointSize: 28)
            }

            drawText(
                item.name,
                in: rect(x + 28, cursorY + 124, cardW - 56, 86, canvasH: canvasH),
                font: roundedFont(size: 31, weight: .semibold),
                color: .white,
                alignment: .left
            )
        }
        cursorY += cardH + 46
    }
}

func drawWidgetsScreen(screenX: CGFloat, screenY: CGFloat, screenW: CGFloat, screenH: CGFloat, canvasH: CGFloat, loc: LocalizedCopy) {
    let pad: CGFloat = 52
    drawText(
        loc.widgetLockTitle,
        in: rect(screenX + pad, screenY + 150, screenW - pad * 2, 52, canvasH: canvasH),
        font: roundedFont(size: 34, weight: .semibold),
        color: zenMuted,
        alignment: .center
    )

    // Medium Widget Card
    let medY = screenY + 250
    let medW = screenW - pad * 2
    let medH: CGFloat = 390
    drawPill(
        frame: rect(screenX + pad, medY, medW, medH, canvasH: canvasH),
        fill: zenCard,
        stroke: zenGlow.withAlphaComponent(0.35),
        lineWidth: 2.5,
        radius: 48
    )

    let ringCx = screenX + pad + 145
    let ringCy = medY + medH / 2
    let ringR: CGFloat = 95
    let bgRing = NSBezierPath(ovalIn: rect(ringCx - ringR, ringCy - ringR, ringR * 2, ringR * 2, canvasH: canvasH))
    zenGlow.withAlphaComponent(0.22).setStroke()
    bgRing.lineWidth = 18
    bgRing.stroke()

    let arc = NSBezierPath()
    arc.appendArc(
        withCenter: pt(ringCx, ringCy, canvasH: canvasH),
        radius: ringR,
        startAngle: 90,
        endAngle: 90 - 288,
        clockwise: true
    )
    arc.lineCapStyle = .round
    zenGlow.setStroke()
    arc.lineWidth = 18
    arc.stroke()

    drawText("8", in: rect(ringCx - 60, ringCy - 52, 120, 68, canvasH: canvasH), font: roundedFont(size: 56, weight: .heavy), color: .white, alignment: .center)
    drawText("MIN", in: rect(ringCx - 60, ringCy + 18, 120, 32, canvasH: canvasH), font: roundedFont(size: 22, weight: .bold), color: zenGlow, alignment: .center)

    let rightX = screenX + pad + 275
    let rightW = medW - 315
    drawText("Haptic Zen", in: rect(rightX, medY + 42, 220, 44, canvasH: canvasH), font: roundedFont(size: 30, weight: .bold), color: .white, alignment: .left)
    drawSymbol("flame.fill", in: rect(rightX + rightW - 140, medY + 46, 26, 26, canvasH: canvasH), color: zenGlow, pointSize: 22)
    drawText("7d", in: rect(rightX + rightW - 110, medY + 42, 60, 40, canvasH: canvasH), font: roundedFont(size: 28, weight: .bold), color: zenGlow, alignment: .left)
    drawText("80%", in: rect(rightX + rightW - 60, medY + 42, 70, 40, canvasH: canvasH), font: monoFont(size: 26, weight: .bold), color: zenGlow, alignment: .right)

    drawPill(frame: rect(rightX, medY + 115, rightW - 30, 58, canvasH: canvasH), fill: zenDark.withAlphaComponent(0.7), stroke: NSColor.white.withAlphaComponent(0.1), lineWidth: 1.5, radius: 18)
    drawText(loc.breathingPatternTitle, in: rect(rightX + 20, medY + 127, rightW - 60, 38, canvasH: canvasH), font: roundedFont(size: 25, weight: .medium), color: .white, alignment: .left)

    let btnW = (rightW - 18) / 2
    drawPill(frame: rect(rightX, medY + 270, btnW, 72, canvasH: canvasH), fill: zenGlow.withAlphaComponent(0.22), stroke: zenGlow.withAlphaComponent(0.5), lineWidth: 1.5, radius: 20)
    drawText(loc.widgetBreathingBtn, in: rect(rightX + 10, medY + 288, btnW - 20, 40, canvasH: canvasH), font: roundedFont(size: 25, weight: .bold), color: zenGlow, alignment: .center)

    drawPill(frame: rect(rightX + btnW + 16, medY + 270, btnW, 72, canvasH: canvasH), fill: zenDark.withAlphaComponent(0.7), stroke: NSColor.white.withAlphaComponent(0.15), lineWidth: 1.5, radius: 20)
    drawText(loc.widgetTexturesBtn, in: rect(rightX + btnW + 26, medY + 288, btnW - 20, 40, canvasH: canvasH), font: roundedFont(size: 25, weight: .medium), color: .white, alignment: .center)

    // Small Widget + Apple Health card side by side
    let rowY = medY + medH + 46
    let smallW = (medW - 32) / 2
    let smallH: CGFloat = 390
    drawPill(frame: rect(screenX + pad, rowY, smallW, smallH, canvasH: canvasH), fill: zenCard, stroke: NSColor.white.withAlphaComponent(0.14), lineWidth: 2, radius: 48)

    let sCx = screenX + pad + smallW / 2
    let sCy = rowY + 150
    let sR: CGFloat = 82
    let sBg = NSBezierPath(ovalIn: rect(sCx - sR, sCy - sR, sR * 2, sR * 2, canvasH: canvasH))
    zenGlow.withAlphaComponent(0.22).setStroke()
    sBg.lineWidth = 14
    sBg.stroke()

    let sArc = NSBezierPath()
    sArc.appendArc(withCenter: pt(sCx, sCy, canvasH: canvasH), radius: sR, startAngle: 90, endAngle: 90 - 288, clockwise: true)
    sArc.lineCapStyle = .round
    zenGlow.setStroke()
    sArc.lineWidth = 14
    sArc.stroke()

    drawText("8m", in: rect(sCx - 60, sCy - 24, 120, 50, canvasH: canvasH), font: roundedFont(size: 38, weight: .bold), color: .white, alignment: .center)
    drawText(loc.widgetCalmToday, in: rect(screenX + pad + 20, rowY + 275, smallW - 40, 40, canvasH: canvasH), font: roundedFont(size: 26, weight: .semibold), color: .white, alignment: .center)
    drawText("80% • 10m", in: rect(screenX + pad + 20, rowY + 320, smallW - 40, 36, canvasH: canvasH), font: roundedFont(size: 24, weight: .medium), color: zenGlow, alignment: .center)

    let hX = screenX + pad + smallW + 32
    drawPill(frame: rect(hX, rowY, smallW, smallH, canvasH: canvasH), fill: zenCard, stroke: NSColor.white.withAlphaComponent(0.14), lineWidth: 2, radius: 48)
    drawSymbol("heart.text.square.fill", in: rect(hX + smallW / 2 - 48, rowY + 86, 96, 96, canvasH: canvasH), color: zenGlow, pointSize: 72)
    drawText("Apple Health", in: rect(hX + 20, rowY + 220, smallW - 40, 44, canvasH: canvasH), font: roundedFont(size: 28, weight: .bold), color: .white, alignment: .center)
    drawText("Mindful Minutes", in: rect(hX + 20, rowY + 272, smallW - 40, 40, canvasH: canvasH), font: roundedFont(size: 24, weight: .medium), color: zenMuted, alignment: .center)
}

// MARK: - Main Entrypoint
let fm = FileManager.default
let root = URL(fileURLWithPath: fm.currentDirectoryPath)
var count = 0

for spec in sizeSpecs {
    for loc in localizations {
        let dir = root
            .appendingPathComponent("docs/screenshots")
            .appendingPathComponent(spec.folderName)
            .appendingPathComponent(loc.lang)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        for (idx, screen) in loc.screens.enumerated() {
            let outURL = dir.appendingPathComponent(screen.filename)
            try drawScreenshot(spec: spec, loc: loc, screenIndex: idx, outURL: outURL)
            count += 1
        }
    }
}

print("Generated \(count) App Store screenshots successfully.")
