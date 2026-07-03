import CoreGraphics
import Foundation
import SwiftUI

/// The two sheen looks the Pillowmaker tool exposes. Mirrors the web store's
/// `highlightStyle` union; drives which highlight-layer stack ``PillowView``
/// composites over the gradient.
public enum PillowHighlightStyle: String, Equatable, Sendable {
    case natural
    case shiny
}

/// A declarative description of a mesh-gradient "pillow".
///
/// This mirrors the `config` payload exported by the Pillowmaker tool
/// (`type: "pillowmaker-shape"`). A ``PillowView`` turns a configuration into a
/// rendered, optionally animated, gradient clipped to the pillow shape.
public struct PillowConfiguration: Equatable, Sendable {
    /// The palette. 1...10 colors; more colors create more complex patterns.
    public var colors: [Color]
    /// Normalized (0...1) anchor point per color. Same count as ``colors``.
    public var meshPoints: [CGPoint]

    public var waveX: Double
    public var waveY: Double
    public var waveXShift: Double
    public var waveYShift: Double

    public var mixing: Double
    public var grainMixer: Double
    public var grainOverlay: Double
    public var highlightGrain: Double
    /// Which sheen stack to composite. Defaults to ``PillowHighlightStyle/shiny``,
    /// matching the web store's default and every current preset.
    public var highlightStyle: PillowHighlightStyle
    /// Opacity (0...1) of a solid-black `mix-blend-overlay` layer composited over
    /// the whole pillow. Mirrors the web tool's Contrast slider.
    public var contrast: Double

    public var scale: Double
    /// Rotation in degrees.
    public var rotation: Double
    public var offsetX: Double
    public var offsetY: Double

    /// Continuous drift speed for the wave phase. `0` means the pillow is still.
    public var speed: Double

    public init(
        colors: [Color],
        meshPoints: [CGPoint]? = nil,
        waveX: Double = 0.5,
        waveY: Double = 0.5,
        waveXShift: Double = 0,
        waveYShift: Double = 0,
        mixing: Double = 0.8,
        grainMixer: Double = 0.15,
        grainOverlay: Double = 0.1,
        highlightGrain: Double = 0.6,
        highlightStyle: PillowHighlightStyle = .shiny,
        contrast: Double = 0.25,
        scale: Double = 1,
        rotation: Double = 0,
        offsetX: Double = 0,
        offsetY: Double = 0,
        speed: Double = 0
    ) {
        self.colors = colors
        self.meshPoints = meshPoints ?? PillowConfiguration.defaultMeshPoints(count: colors.count)
        self.waveX = waveX
        self.waveY = waveY
        self.waveXShift = waveXShift
        self.waveYShift = waveYShift
        self.mixing = mixing
        self.grainMixer = grainMixer
        self.grainOverlay = grainOverlay
        self.highlightGrain = highlightGrain
        self.highlightStyle = highlightStyle
        self.contrast = contrast
        self.scale = scale
        self.rotation = rotation
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.speed = speed
    }

    /// Golden-angle spiral seeding, used only when a config supplies no explicit
    /// mesh points (matches the web store's `spreadPointForCount`).
    public static func defaultMeshPoints(count: Int) -> [CGPoint] {
        let goldenAngle = 2.399963229728653
        let denom = Double(max(1, count))
        return (0..<max(0, count))
            .map { i in
                let t = (Double(i) + 0.5) / denom
                let radius = t.squareRoot() * 0.34
                let angle = Double(i) * goldenAngle
                return CGPoint(
                    x: clamp01(0.5 + cos(angle) * radius),
                    y: clamp01(0.5 + sin(angle) * radius)
                )
            }
    }
}

private func clamp01(_ n: Double) -> Double { min(1, max(0, n)) }

// MARK: - Loading exported "pillowmaker-shape" JSON

extension PillowConfiguration {
    private struct Export: Decodable {
        struct Point: Decodable { let x: Double; let y: Double }
        struct Config: Decodable {
            let colors: [String]
            let meshPoints: [Point]?
            let speed: Double?
            let waveX: Double
            let waveY: Double
            let waveXShift: Double
            let waveYShift: Double
            let mixing: Double
            let grainMixer: Double
            let grainOverlay: Double
            let highlightGrain: Double
            let highlightStyle: String?
            let contrast: Double?
            let scale: Double
            let rotation: Double
            let offsetX: Double
            let offsetY: Double
        }
        let config: Config
    }

    /// Decodes a configuration from Pillowmaker's exported JSON.
    public init(pillowmakerJSON data: Data) throws {
        let export = try JSONDecoder().decode(Export.self, from: data)
        let c = export.config
        self.init(
            colors: c.colors.map { Color(pillowHex: $0) },
            meshPoints: c.meshPoints?.map { CGPoint(x: $0.x, y: $0.y) },
            waveX: c.waveX,
            waveY: c.waveY,
            waveXShift: c.waveXShift,
            waveYShift: c.waveYShift,
            mixing: c.mixing,
            grainMixer: c.grainMixer,
            grainOverlay: c.grainOverlay,
            highlightGrain: c.highlightGrain,
            highlightStyle: PillowHighlightStyle(rawValue: c.highlightStyle ?? "") ?? .shiny,
            contrast: c.contrast ?? 0.25,
            scale: c.scale,
            rotation: c.rotation,
            offsetX: c.offsetX,
            offsetY: c.offsetY,
            speed: c.speed ?? 0
        )
    }
}

// MARK: - Insurance presets

/// Product presets, taken verbatim from the Pillowmaker tool's `presets.ts`
/// (each an exported `pillowmaker-shape` config with hand-placed mesh points).
/// The tool's shared `presetDefaults` equal this type's `init` defaults, so
/// only the per-preset values are spelled out.
extension PillowConfiguration {
    public static let car = PillowConfiguration(
        colors: [
            Color(pillowHex: "#B8D7A2"),
            Color(pillowHex: "#295652"),
            Color(pillowHex: "#FFF265"),
            Color(pillowHex: "#FFF79E"),
            Color(pillowHex: "#295652"),
        ],
        meshPoints: [
            CGPoint(x: 0.40018463134765625, y: 0.766632080078125),
            CGPoint(x: 0.093963623046875, y: 0.2287139892578125),
            CGPoint(x: 0.939178466796875, y: 0.6595001220703125),
            CGPoint(x: 0.9654159545898438, y: 0.384429931640625),
            CGPoint(x: 0.8343582153320312, y: 0.9221343994140625),
        ],
        waveX: 0,
        waveY: 0,
        waveXShift: 0,
        waveYShift: 0.96
    )

    public static let accident = PillowConfiguration(
        colors: [
            Color(pillowHex: "#F2D588"),
            Color(pillowHex: "#6E190C"),
            Color(pillowHex: "#FF513A"),
            Color(pillowHex: "#F2D588"),
        ],
        meshPoints: [
            CGPoint(x: 0.9448928833007812, y: 0.33698272705078125),
            CGPoint(x: 0.8172454833984375, y: 0.92388916015625),
            CGPoint(x: 0.5082168579101562, y: 0.1909637451171875),
            CGPoint(x: 0.21875, y: 0.2257537841796875),
        ],
        waveX: 0.16,
        waveY: 0.07,
        waveXShift: 0,
        waveYShift: 0.96
    )

    public static let safety = PillowConfiguration(
        colors: [
            Color(pillowHex: "#8F3EFF"),
            Color(pillowHex: "#602F4D"),
            Color(pillowHex: "#BEE1F4"),
            Color(pillowHex: "#F5D6E9"),
            Color(pillowHex: "#E89ACA"),
        ],
        meshPoints: [
            CGPoint(x: 0.45870208740234375, y: 0),
            CGPoint(x: 0.8172454833984375, y: 0.92388916015625),
            CGPoint(x: 0.13764190673828125, y: 0.893524169921875),
            CGPoint(x: 0.9672088623046875, y: 0.5867767333984375),
            CGPoint(x: 0.01390838623046875, y: 0.6537094116210938),
        ],
        waveX: 0.12,
        waveY: 0.07,
        waveXShift: 0,
        waveYShift: 0.96
    )

    public static let pet = PillowConfiguration(
        colors: [
            Color(pillowHex: "#E3BFD5"),
            Color(pillowHex: "#30577E"),
            Color(pillowHex: "#D0ECFB"),
            Color(pillowHex: "#30577E"),
        ],
        meshPoints: [
            CGPoint(x: 0.702667236328125, y: 0.0213623046875),
            CGPoint(x: 0.9766693115234375, y: 0.47806549072265625),
            CGPoint(x: 0.22634124755859375, y: 0.9085540771484375),
            CGPoint(x: 0.20092010498046875, y: 0.05889892578125),
        ],
        waveX: 0.17,
        waveY: 0.07,
        waveXShift: 0,
        waveYShift: 0.96
    )

    public static let dog = PillowConfiguration(
        colors: [
            Color(pillowHex: "#E3BFD5"),
            Color(pillowHex: "#30577E"),
            Color(pillowHex: "#D0ECFB"),
            Color(pillowHex: "#30577E"),
            Color(pillowHex: "#B1CF9B"),
        ],
        meshPoints: [
            CGPoint(x: 0.21285247802734375, y: 0.887237548828125),
            CGPoint(x: 0.9766693115234375, y: 0.47806549072265625),
            CGPoint(x: 0.5908737182617188, y: 0.0571136474609375),
            CGPoint(x: 0.20092010498046875, y: 0.05889892578125),
            CGPoint(x: 0.11893463134765625, y: 0.31458282470703125),
        ],
        waveX: 0.17,
        waveY: 0.07,
        waveXShift: 0,
        waveYShift: 0.96
    )

    public static let cat = PillowConfiguration(
        colors: [
            Color(pillowHex: "#E3BFD5"),
            Color(pillowHex: "#30577E"),
            Color(pillowHex: "#D0ECFB"),
            Color(pillowHex: "#30577E"),
            Color(pillowHex: "#D4F5BC"),
        ],
        meshPoints: [
            CGPoint(x: 0.226165771484375, y: 0.33614349365234375),
            CGPoint(x: 0.9730987548828125, y: 0.40558624267578125),
            CGPoint(x: 0.2626800537109375, y: 0.903350830078125),
            CGPoint(x: 0.20092010498046875, y: 0.05889892578125),
            CGPoint(x: 0.520477294921875, y: 0.9024581909179688),
        ],
        waveX: 0.04,
        waveY: 0.07,
        waveXShift: 0,
        waveYShift: 0.96
    )

    public static let student = PillowConfiguration(
        colors: [
            Color(pillowHex: "#F9CEC8"),
            Color(pillowHex: "#F2D588"),
            Color(pillowHex: "#FF7D6C"),
            Color(pillowHex: "#FFEEEB"),
        ],
        meshPoints: [
            CGPoint(x: 0.8878707885742188, y: 0.341400146484375),
            CGPoint(x: 0.25054168701171875, y: 0.7023239135742188),
            CGPoint(x: 0.221771240234375, y: 0.05384063720703125),
            CGPoint(x: 0.908111572265625, y: 0.696258544921875),
        ],
        waveX: 0.12,
        waveY: 0.11,
        waveXShift: 0.2,
        waveYShift: 0.1
    )

    public static let home = PillowConfiguration(
        colors: [
            Color(pillowHex: "#EB66B8"),
            Color(pillowHex: "#F0EBAD"),
            Color(pillowHex: "#602F4D"),
            Color(pillowHex: "#85D4FF"),
            Color(pillowHex: "#EB66B8"),
            Color(pillowHex: "#1F3E5C"),
        ],
        meshPoints: [
            CGPoint(x: 0.30982208251953125, y: 0.8776626586914062),
            CGPoint(x: 0.12369537353515625, y: 0.5168380737304688),
            CGPoint(x: 0.9864959716796875, y: 0.6626205444335938),
            CGPoint(x: 0.7218399047851562, y: 0.03326416015625),
            CGPoint(x: 0.5131072998046875, y: 0.95654296875),
            CGPoint(x: 0.9853973388671875, y: 0.3932952880859375),
        ],
        waveX: 0.09,
        waveY: 0,
        waveXShift: 0,
        waveYShift: 0.37
    )

    public static let homeowner = PillowConfiguration(
        colors: [
            Color(pillowHex: "#EB66B8"),
            Color(pillowHex: "#D0ECFB"),
            Color(pillowHex: "#30577E"),
            Color(pillowHex: "#EB66B8"),
        ],
        meshPoints: [
            CGPoint(x: 0.01732635498046875, y: 0.4716644287109375),
            CGPoint(x: 0.4988555908203125, y: 0.7441787719726562),
            CGPoint(x: 0.9474868774414062, y: 0.32346343994140625),
            CGPoint(x: 0.5424118041992188, y: 0),
        ],
        waveX: 0,
        waveY: 0,
        waveXShift: 0,
        waveYShift: 0.37
    )

    public static let rental = PillowConfiguration(
        colors: [
            Color(pillowHex: "#EB66B8"),
            Color(pillowHex: "#1F3E5C"),
            Color(pillowHex: "#EB66B8"),
            Color(pillowHex: "#F0EBAD"),
        ],
        meshPoints: [
            CGPoint(x: 0.01732635498046875, y: 0.4716644287109375),
            CGPoint(x: 0.5422515869140625, y: 0),
            CGPoint(x: 0.5424118041992188, y: 0),
            CGPoint(x: 0.2468719482421875, y: 0.796295166015625),
        ],
        waveX: 0,
        waveY: 0,
        waveXShift: 0,
        waveYShift: 0.37
    )

    public static let house = PillowConfiguration(
        colors: [
            Color(pillowHex: "#EB66B8"),
            Color(pillowHex: "#F0EBAD"),
            Color(pillowHex: "#602F4D"),
            Color(pillowHex: "#EB66B8"),
            Color(pillowHex: "#1F3E5C"),
        ],
        meshPoints: [
            CGPoint(x: 0.30982208251953125, y: 0.8776626586914062),
            CGPoint(x: 0.0988311767578125, y: 0.27973175048828125),
            CGPoint(x: 0.9864959716796875, y: 0.6626205444335938),
            CGPoint(x: 0.6751785278320312, y: 0.01546478271484375),
            CGPoint(x: 0.9884033203125, y: 0.42704010009765625),
        ],
        waveX: 0.09,
        waveY: 0,
        waveXShift: 0,
        waveYShift: 0.37,
        mixing: 0.85
    )

    public static let vacationHome = PillowConfiguration(
        colors: [
            Color(pillowHex: "#85D4FF"),
            Color(pillowHex: "#F0EBAD"),
            Color(pillowHex: "#602F4D"),
            Color(pillowHex: "#EB66B8"),
            Color(pillowHex: "#85D4FF"),
            Color(pillowHex: "#1F3E5C"),
        ],
        meshPoints: [
            CGPoint(x: 0.30982208251953125, y: 0.8776626586914062),
            CGPoint(x: 0.12368011474609375, y: 0.39662933349609375),
            CGPoint(x: 0.9936294555664062, y: 0.39166259765625),
            CGPoint(x: 0.7218399047851562, y: 0.03326416015625),
            CGPoint(x: 0.5131072998046875, y: 0.95654296875),
            CGPoint(x: 0.959686279296875, y: 0.6575851440429688),
        ],
        waveX: 0.09,
        waveY: 0,
        waveXShift: 0,
        waveYShift: 0.37
    )
}

// MARK: - Color <-> shader plumbing

extension Color {
    /// Parses `#RGB`, `#RRGGBB`, or `#RRGGBBAA` into an sRGB color.
    init(pillowHex hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        if s.count == 3 { s = s.map { "\($0)\($0)" }.joined() }
        if s.count == 6 { s += "FF" }
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        let r = Double((value & 0xFF00_0000) >> 24) / 255
        let g = Double((value & 0x00FF_0000) >> 16) / 255
        let b = Double((value & 0x0000_FF00) >> 8) / 255
        let a = Double(value & 0x0000_00FF) / 255
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

extension PillowConfiguration {
    /// Flattened `[r, g, b, a, ...]` in 0...1 for the shader's color buffer.
    func colorComponents() -> [Float] {
        colors.flatMap { color -> [Float] in
            let c = color.pillowRGBA
            return [c.0, c.1, c.2, c.3]
        }
    }

    /// Flattened `[x, y, ...]` normalized mesh points for the shader.
    func pointComponents() -> [Float] {
        var pts = meshPoints
        while pts.count < colors.count {
            pts.append(PillowConfiguration.defaultMeshPoints(count: colors.count)[pts.count])
        }
        return pts.prefix(colors.count).flatMap { [Float($0.x), Float($0.y)] }
    }
}

extension Color {
    /// Resolves the color to straight sRGB components.
    var pillowRGBA: (Float, Float, Float, Float) {
        #if canImport(UIKit)
            let ui = UIColor(self)
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            ui.getRed(&r, green: &g, blue: &b, alpha: &a)
            return (Float(r), Float(g), Float(b), Float(a))
        #else
            return (0, 0, 0, 1)
        #endif
    }
}
