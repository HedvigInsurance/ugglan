import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

/// QR code with a logo in its cleared centre, both drawn in the primary text colour — black in light mode,
/// white in dark mode. The logo should be a template image so it picks up the same fill.
public struct StyledQRCodeView<Logo: View>: View {
    let image: UIImage
    let logoFraction: CGFloat
    let logo: Logo

    /// `logoFraction` must match the one the image was drawn with, so the logo fills the hole left for it.
    public init(
        image: UIImage,
        logoFraction: CGFloat = StyledQRCode.defaultLogoFraction,
        @ViewBuilder logo: () -> Logo
    ) {
        self.image = image
        self.logoFraction = logoFraction
        self.logo = logo()
    }

    public var body: some View {
        GeometryReader { proxy in
            Image(uiImage: image)
                .resizable()
                .overlay {
                    logo
                        .frame(width: proxy.size.width * logoFraction * 0.8)
                }
                .foregroundColor(hTextColor.Opaque.primary)
        }
    }
}

extension StyledQRCodeView where Logo == EmptyView {
    /// A code without a logo — pair it with an image drawn with `logoFraction: 0`.
    public init(image: UIImage) {
        self.init(image: image, logoFraction: 0) { EmptyView() }
    }
}

/// Draws a QR code in a rounded style — round modules, rounded finder patterns and an empty centre for
/// a logo — as a template image, so the caller decides the fill.
public enum StyledQRCode {
    /// Share of the code's width left empty in the middle for the logo.
    public static let defaultLogoFraction: CGFloat = 0.25

    /// How much of the code can be lost and still scan. Lower levels need fewer modules for the same message,
    /// so every module — the finder patterns included — draws larger at a given size.
    public enum CorrectionLevel: String {
        case low = "L"
        case medium = "M"
        case quartile = "Q"
        /// Needed whenever the centre is cleared for a logo.
        case high = "H"
    }

    private static let moduleSize: CGFloat = 12
    private static let finderSize = 7
    private static let ciContext = CIContext()

    public static func image(
        for message: String,
        logoFraction: CGFloat = defaultLogoFraction,
        correctionLevel: CorrectionLevel = .high
    ) -> UIImage? {
        guard let modules = modules(for: message, correctionLevel: correctionLevel) else { return nil }
        let count = modules.count
        let finderOrigins = [
            (column: 0, row: 0),
            (column: count - finderSize, row: 0),
            (column: 0, row: count - finderSize),
        ]
        let logo = logoRange(count: count, logoFraction: logoFraction)

        /// Modules covered by a finder pattern or the logo are left to those instead.
        func isCovered(column: Int, row: Int) -> Bool {
            let inFinder = finderOrigins.contains {
                ($0.column..<$0.column + finderSize).contains(column) && ($0.row..<$0.row + finderSize).contains(row)
            }
            return inFinder || (logo.contains(column) && logo.contains(row))
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let side = CGFloat(count) * moduleSize
        let image = UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format)
            .image { _ in
                UIColor.black.setFill()
                for row in 0..<count {
                    for column in 0..<count where modules[row][column] && !isCovered(column: column, row: row) {
                        drawModule(column: column, row: row)
                    }
                }
                for origin in finderOrigins {
                    drawFinder(column: origin.column, row: origin.row)
                }
            }
        return image.withRenderingMode(.alwaysTemplate)
    }

    /// Reads the module grid out of Core Image's 1-pixel-per-module output, trimming its quiet zone.
    private static func modules(for message: String, correctionLevel: CorrectionLevel) -> [[Bool]]? {
        guard let data = message.data(using: .utf8) else { return nil }
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = correctionLevel.rawValue
        guard
            let output = filter.outputImage,
            let cgImage = ciContext.createCGImage(output, from: output.extent)
        else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        var pixels = [UInt8](repeating: 255, count: width * height)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard
                let context = CGContext(
                    data: buffer.baseAddress,
                    width: width,
                    height: height,
                    bitsPerComponent: 8,
                    bytesPerRow: width,
                    space: CGColorSpaceCreateDeviceGray(),
                    bitmapInfo: CGImageAlphaInfo.none.rawValue
                )
            else { return false }
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return nil }

        func isDark(_ x: Int, _ y: Int) -> Bool { pixels[y * width + x] < 128 }
        // The quiet zone is equally wide on every side and the top-left finder fills its corner, so the
        // first dark pixel on the diagonal is where the grid starts.
        guard let start = (0..<min(width, height)).first(where: { isDark($0, $0) }) else { return nil }
        let count = width - 2 * start
        guard count > 0, start + count <= height else { return nil }

        return (start..<start + count).map { y in (start..<start + count).map { x in isDark(x, y) } }
    }

    /// Module indices to clear for the logo, centred and matching the grid's parity.
    private static func logoRange(count: Int, logoFraction: CGFloat) -> Range<Int> {
        // No logo: clear nothing, rather than the single module the parity fix-up below would add.
        guard logoFraction > 0 else { return 0..<0 }
        var side = Int((CGFloat(count) * logoFraction).rounded())
        if (count - side) % 2 != 0 { side += 1 }
        let start = (count - side) / 2
        return start..<start + side
    }

    private static func rect(column: Int, row: Int, size: Int = 1) -> CGRect {
        CGRect(
            x: CGFloat(column) * moduleSize,
            y: CGFloat(row) * moduleSize,
            width: CGFloat(size) * moduleSize,
            height: CGFloat(size) * moduleSize
        )
    }

    private static func drawModule(column: Int, row: Int) {
        let inset = moduleSize * 0.08
        UIBezierPath(ovalIn: rect(column: column, row: row).insetBy(dx: inset, dy: inset)).fill()
    }

    /// A one-module ring around a rounded 3×3 eye. The ring's hole is rounded concentrically with its
    /// outside so the ring keeps an even thickness around the corners.
    private static func drawFinder(column: Int, row: Int) {
        let outer = rect(column: column, row: row, size: finderSize)
        let ring = circularRoundedRect(outer, radius: moduleSize * 1.8)
        ring.append(circularRoundedRect(outer.insetBy(dx: moduleSize, dy: moduleSize), radius: moduleSize * 0.8))
        ring.usesEvenOddFillRule = true
        ring.fill()

        let eye = outer.insetBy(dx: moduleSize * 2, dy: moduleSize * 2)
        UIBezierPath(roundedRect: eye, cornerRadius: moduleSize * 0.6).fill()
    }

    /// Circular-arc corners. `UIBezierPath(roundedRect:cornerRadius:)` draws continuous ones, which
    /// wouldn't stay concentric between the ring's outside and its hole.
    private static func circularRoundedRect(_ rect: CGRect, radius: CGFloat) -> UIBezierPath {
        UIBezierPath(cgPath: CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
    }
}
