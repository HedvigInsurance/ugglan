import SwiftUI

/// The call's orb: a soft Hedvig pillow (the shape and mesh-gradient look of Hedvig's product pillows), shaded like
/// one side of a rounded sphere, with an outline that flows like a blob. Its colours keep drifting through Hedvig's
/// product palettes and its outline moves like a blob, each corner on its own. When the member speaks it shrinks and
/// its colours shift; when Hedvig speaks it grows and brightens.
struct VoiceOrbView: View {
    let status: VoiceCallStatus
    /// Hedvig's and the member's audio levels, read every frame.
    let levels: @Sendable () -> VoiceAudioLevels
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Clocks and eased values that live across frames, so nothing ever jumps when the status changes.
    @State private var motion = OrbMotion()
    @State private var startDate = Date()

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            let time = reduceMotion ? 0 : context.date.timeIntervalSince(startDate)
            Canvas { canvas, size in
                let now = reduceMotion ? VoiceAudioLevels(agent: 0, member: 0) : levels()
                // Each side only counts while it has the turn, so the mic picking up Hedvig doesn't shrink the orb.
                let frame = motion.advance(
                    to: time,
                    agent: status == .speaking ? now.agent : 0,
                    member: status == .listening ? now.member : 0
                )
                draw(in: &canvas, size: size, frame: frame)
            }
        }
        .opacity(isOver ? 0.35 : 1)
    }

    private var isOver: Bool {
        switch status {
        case .ended, .failed: return true
        default: return false
        }
    }

    // MARK: - Drawing

    private func draw(in canvas: inout GraphicsContext, size: CGSize, frame: OrbMotion.Frame) {
        let side = min(size.width, size.height)
        // At rest the pillow is 64% of the frame: up to 76% as Hedvig speaks, down to 56% as the member does. The
        // rest is room for the glow and the turning corners, which would otherwise be cut off in a square.
        let scale = side * (0.64 + 0.12 * frame.agent - 0.08 * frame.member) / Self.pillowSize
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let half = Self.pillowSize / 2
        // The outline changes shape like a blob (see `blobPath`); the light, shade and colours stay put.
        let outline = Self.blobPath(time: frame.time, energy: frame.agent + 0.6 * frame.member)
            .applying(
                CGAffineTransform(translationX: center.x, y: center.y)
                    .scaledBy(x: scale, y: scale)
                    .translatedBy(x: -half, y: -half)
            )
        // The unturned pillow's box: the light, shade and colours are laid out on this, so they don't turn.
        let bounds = CGRect(
            x: center.x - half * scale,
            y: center.y - half * scale,
            width: Self.pillowSize * scale,
            height: Self.pillowSize * scale
        )
        let cover = bounds.insetBy(dx: -bounds.width * 0.2, dy: -bounds.height * 0.2)

        // A soft glow behind it that brightens with Hedvig's voice, then a soft shadow to sit it on the background.
        var glow = canvas
        glow.addFilter(.blur(radius: side * 0.07))
        glow.fill(outline, with: .color(frame.palette[2].color.opacity(0.1 + 0.55 * frame.agent)))
        var shadow = canvas
        shadow.addFilter(.blur(radius: side * 0.05))
        shadow.fill(
            outline.applying(CGAffineTransform(translationX: 0, y: side * 0.035)),
            with: .color(.black.opacity(0.4))
        )

        canvas.drawLayer { layer in
            // Hedvig speaking lifts the whole pillow; the member speaking turns its colours slightly.
            layer.addFilter(.brightness(0.26 * frame.agent))
            layer.addFilter(.saturation(1 + 0.3 * frame.agent))
            layer.addFilter(.hueRotation(.degrees(-50 * frame.member)))
            layer.clip(to: outline)
            let palette = frame.palette
            layer.fill(Path(cover), with: .color(palette[0].color))
            // The mesh: one soft colour field per point, drifting over the pillow.
            for (index, base) in Self.meshPoints.enumerated() {
                let phase = Double(index) * 1.7
                let point = CGPoint(
                    x: bounds.minX + bounds.width * (base.x + 0.2 * sin(frame.drift * 0.9 + phase)),
                    y: bounds.minY + bounds.height * (base.y + 0.2 * cos(frame.drift * 0.7 + phase * 1.3))
                )
                let radius = bounds.width * 0.62
                let color = palette[(index + 1) % palette.count].color
                layer.fill(
                    Path(
                        ellipseIn: CGRect(
                            x: point.x - radius,
                            y: point.y - radius,
                            width: radius * 2,
                            height: radius * 2
                        )
                    ),
                    with: .radialGradient(
                        Gradient(colors: [color, color.opacity(0.55), color.opacity(0)]),
                        center: point,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
            Self.shadeAsSphere(&layer, outline: outline, bounds: bounds, center: center)
            // A whisper of grain, just enough to feel like fabric.
            var grain = layer
            grain.blendMode = .overlay
            grain.opacity = 0.05
            grain.draw(Self.grain, in: cover)
        }
    }

    /// Light and shade that make the flat pillow read as the front of a rounded sphere: the edges fall away into
    /// shadow, light hits the top left, and a little light bounces back along the bottom edge.
    private static func shadeAsSphere(
        _ layer: inout GraphicsContext,
        outline: Path,
        bounds: CGRect,
        center: CGPoint
    ) {
        let width = bounds.width
        // Paint over more than the pillow's box: the blob bulges past it as it moves, and the bulge needs the
        // same shade as the rest of the edge.
        let canvasArea = bounds.insetBy(dx: -width * 0.25, dy: -bounds.height * 0.25)
        // Edges curving away from the viewer.
        layer.fill(
            Path(canvasArea),
            with: .radialGradient(
                Gradient(stops: [
                    .init(color: .black.opacity(0), location: 0.55),
                    .init(color: .black.opacity(0.18), location: 0.82),
                    .init(color: .black.opacity(0.38), location: 1),
                ]),
                center: CGPoint(x: center.x - width * 0.06, y: center.y - width * 0.08),
                startRadius: 0,
                endRadius: width * 0.62
            )
        )
        // A soft inner shadow right along the outline, so the edge rolls away instead of ending flat.
        var rim = layer
        rim.addFilter(.blur(radius: width * 0.035))
        rim.stroke(outline, with: .color(.black.opacity(0.3)), lineWidth: width * 0.07)
        // Light reflected back from below.
        var bounce = layer
        bounce.blendMode = .screen
        bounce.fill(
            Path(canvasArea),
            with: .radialGradient(
                Gradient(colors: [.white.opacity(0.12), .white.opacity(0)]),
                center: CGPoint(x: center.x + width * 0.15, y: bounds.maxY),
                startRadius: 0,
                endRadius: width * 0.4
            )
        )
        // The broad, soft highlight and its brighter core, top left.
        var light = layer
        light.blendMode = .screen
        let highlight = CGPoint(x: bounds.minX + width * 0.32, y: bounds.minY + bounds.height * 0.27)
        light.fill(
            Path(canvasArea),
            with: .radialGradient(
                Gradient(colors: [.white.opacity(0.32), .white.opacity(0.08), .white.opacity(0)]),
                center: highlight,
                startRadius: 0,
                endRadius: width * 0.5
            )
        )
        light.fill(
            Path(canvasArea),
            with: .radialGradient(
                Gradient(colors: [.white.opacity(0.22), .white.opacity(0)]),
                center: highlight,
                startRadius: 0,
                endRadius: width * 0.16
            )
        )
    }

    // MARK: - The pillow

    /// Size of the pillow outline, from Hedvig's pillow mask (pillowmaker `mask.svg`, a 303 × 303 view box).
    private static let pillowSize = 303.0

    /// The pillow outline as four cubic curves, sampled once into points around the centre.
    private static let pillowPoints: [CGPoint] = {
        let p = { (x: Double, y: Double) in CGPoint(x: x, y: y) }
        let curves: [(CGPoint, CGPoint, CGPoint, CGPoint)] = [
            (p(0, 151.392), p(0, 259.796), p(47.6, 302.785), p(151.58, 302.785)),
            (p(151.58, 302.785), p(255.558, 302.785), p(302.785, 261.701), p(302.785, 151.392)),
            (p(302.785, 151.392), p(302.785, 41.084), p(255.558, 0), p(151.58, 0)),
            (p(151.58, 0), p(47.6, 0), p(0, 42.989), p(0, 151.392)),
        ]
        let steps = 36
        return curves.flatMap { a, b, c, d in
            (0..<steps)
                .map { step in
                    let t = Double(step) / Double(steps)
                    let u = 1 - t
                    let x = u * u * u * a.x + 3 * u * u * t * b.x + 3 * u * t * t * c.x + t * t * t * d.x
                    let y = u * u * u * a.y + 3 * u * u * t * b.y + 3 * u * t * t * c.y + t * t * t * d.y
                    return CGPoint(x: x, y: y)
                }
        }
    }()

    /// The pillow, alive like a blob: each corner swells, shrinks and drifts round a little on its own clock,
    /// slow waves ripple along the edges, and the whole shape gently squashes and stretches. `energy` (a voice,
    /// 0...1) makes all of it a bit livelier.
    private static func blobPath(time: Double, energy: Double) -> Path {
        let center = CGPoint(x: pillowSize / 2, y: pillowSize / 2)
        // Four soft lobes, one per corner. Their own speeds keep them out of step, so it never looks like turning.
        let lobes: [(angle: Double, strength: Double)] = (0..<4)
            .map { index in
                let k = Double(index)
                let speed = 0.31 + 0.09 * k
                let angle = Double.pi / 4 + k * Double.pi / 2 + 0.32 * sin(time * speed * 0.8 + k * 1.9)
                let strength = (0.03 + 0.03 * energy) * sin(time * speed + k * 2.4)
                return (angle, strength)
            }
        let breath = 0.03 * sin(time * 0.45)
        let stretchX = 1 + breath + 0.015 * energy * sin(time * 2.1)
        let stretchY = 1 - breath * 0.8 + 0.015 * energy * sin(time * 2.1 + 1.2)
        let points = pillowPoints.map { point -> CGPoint in
            let dx = point.x - center.x
            let dy = point.y - center.y
            let angle = atan2(dy, dx)
            var push =
                (0.012 + 0.012 * energy)
                * (sin(2 * angle + time * 0.5 + 1.2 * sin(time * 0.23))
                    + 0.6 * sin(3 * angle - time * 0.65 + 1.5 * sin(time * 0.17 + 1)))
            for lobe in lobes {
                // Shortest angle to the lobe, then a soft bump around it.
                let offset = atan2(sin(angle - lobe.angle), cos(angle - lobe.angle))
                push += lobe.strength * exp(-(offset * offset) / 0.28)
            }
            let factor = 1 + push
            return CGPoint(x: center.x + dx * factor * stretchX, y: center.y + dy * factor * stretchY)
        }
        // A smooth closed curve through the points (Catmull-Rom as cubic Béziers).
        var path = Path()
        let count = points.count
        path.move(to: points[0])
        for index in 0..<count {
            let p0 = points[(index - 1 + count) % count]
            let p1 = points[index]
            let p2 = points[(index + 1) % count]
            let p3 = points[(index + 2) % count]
            path.addCurve(
                to: p2,
                control1: CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6),
                control2: CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
            )
        }
        path.closeSubpath()
        return path
    }

    /// Where each colour field sits, as fractions of the pillow (from the pillowmaker Car preset's mesh).
    private static let meshPoints: [CGPoint] = [
        CGPoint(x: 0.4, y: 0.77), CGPoint(x: 0.09, y: 0.23), CGPoint(x: 0.94, y: 0.66),
        CGPoint(x: 0.97, y: 0.38), CGPoint(x: 0.83, y: 0.92),
    ]

    /// Static noise, drawn over the pillow for the printed-fabric grain.
    private static let grain: Image = {
        let side = 256
        var bytes = [UInt8](repeating: 0, count: side * side)
        var seed: UInt64 = 0x9E37_79B9_7F4A_7C15
        for index in bytes.indices {
            seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            bytes[index] = UInt8(truncatingIfNeeded: seed >> 56)
        }
        let provider = CGDataProvider(data: Data(bytes) as CFData)!
        let image = CGImage(
            width: side,
            height: side,
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            bytesPerRow: side,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )!
        return Image(decorative: image, scale: 1)
    }()
}

#Preview {
    VoiceOrbView(status: .speaking, levels: { VoiceAudioLevels(agent: 0.5, member: 0) })
        .frame(width: 300, height: 300)
        .padding(40)
        .background(Color(red: 0.05, green: 0.047, blue: 0.043))
}

// MARK: - Motion

/// Everything about the orb that carries from frame to frame. A class, so the Canvas can update it while drawing.
private final class OrbMotion {
    struct Frame {
        /// Seconds since the orb appeared, for the outline's waves.
        let time: Double
        /// Clock for the colour fields' drift.
        let drift: Double
        /// Hedvig's voice, eased, 0...1.
        let agent: Double
        /// The member's voice, eased, 0...1.
        let member: Double
        /// The current colours, blended between two Hedvig palettes.
        let palette: [RGB]
    }

    private var lastTime: Double?
    private var agent = 0.0
    private var member = 0.0

    /// Seconds from one palette to the next. The colours are always on their way somewhere.
    private static let paletteSeconds = 8.0

    func advance(to time: Double, agent agentTarget: Double, member memberTarget: Double) -> Frame {
        let delta = min(max(time - (lastTime ?? time), 0), 0.1)
        lastTime = time
        agent = Self.ease(agent, toward: agentTarget, delta: delta)
        member = Self.ease(member, toward: memberTarget, delta: delta)

        let colorClock = time / Self.paletteSeconds
        let palettes = HedvigPalette.all
        let index = Int(colorClock.rounded(.down))
        let blend = smoothstep(colorClock - Double(index))
        let from = palettes[index % palettes.count]
        let to = palettes[(index + 1) % palettes.count]
        let palette = zip(from, to).map { $0.mixed(with: $1, by: blend) }
        return Frame(
            time: time,
            drift: time * 0.4,
            agent: agent,
            member: member,
            palette: palette
        )
    }

    /// Eased by time, not per frame: rises in about a fifth of a second, settles back over about half a second.
    private static func ease(_ value: Double, toward target: Double, delta: Double) -> Double {
        let target = min(max(target, 0), 1)
        let rate = target > value ? 5.0 : 2.0
        return value + (target - value) * (1 - exp(-delta * rate))
    }

    private func smoothstep(_ x: Double) -> Double {
        let t = min(max(x, 0), 1)
        return t * t * (3 - 2 * t)
    }
}

private struct RGB {
    let red: Double
    let green: Double
    let blue: Double

    init(_ hex: UInt32) {
        red = Double((hex >> 16) & 0xFF) / 255
        green = Double((hex >> 8) & 0xFF) / 255
        blue = Double(hex & 0xFF) / 255
    }

    private init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    var color: Color { Color(red: red, green: green, blue: blue) }

    func mixed(with other: RGB, by t: Double) -> RGB {
        RGB(
            red: red + (other.red - red) * t,
            green: green + (other.green - green) * t,
            blue: blue + (other.blue - blue) * t
        )
    }
}

/// Hedvig's product pillow palettes (from pillowmaker), five colours each, the first being the base.
private enum HedvigPalette {
    static let all: [[RGB]] = [
        // Home
        [RGB(0x1F3E5C), RGB(0xEB66B8), RGB(0xF0EBAD), RGB(0x85D4FF), RGB(0x602F4D)],
        // Pet
        [RGB(0x30577E), RGB(0xE3BFD5), RGB(0xD0ECFB), RGB(0xD4F5BC), RGB(0x30577E)],
        // Car
        [RGB(0x295652), RGB(0xB8D7A2), RGB(0xFFF265), RGB(0xFFF79E), RGB(0x295652)],
        // Safety
        [RGB(0x602F4D), RGB(0x8F3EFF), RGB(0xBEE1F4), RGB(0xF5D6E9), RGB(0xE89ACA)],
    ]
}
