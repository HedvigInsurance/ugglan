import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import hCore
import hCoreUI

/// No success case: an approved consent closes the Swish flow rather than rendering a screen.
enum SwishConsentState: Equatable {
    case waiting
    case failed(error: String?)
}

struct SwishPayinConsentScreen: View {
    @StateObject private var vm: SwishPayinConsentViewModel
    @EnvironmentObject private var router: NavigationRouter
    private let onConnected: () async -> Void

    init(
        phoneNumber: String,
        orderId: String?,
        url: String?,
        state: SwishConsentState = .waiting,
        onConnected: @escaping () async -> Void = {}
    ) {
        _vm = StateObject(
            wrappedValue: SwishPayinConsentViewModel(
                phoneNumber: phoneNumber,
                orderId: orderId,
                url: url,
                state: state
            )
        )
        self.onConnected = onConnected
    }

    var body: some View {
        hForm {
            VStack(spacing: .padding32) {
                switch vm.state {
                case .waiting:
                    if let qrImage = vm.qrImage {
                        SwishQRCodeView(image: qrImage)
                            .frame(width: 180, height: 180)
                            .accessibilityHidden(true)

                        if vm.canOpenSwish {
                            DotsActivityIndicator(.standard)
                                .useDarkColor
                        }
                    }
                case .failed:
                    PaymentConnectionPairGraphic(provider: .swish, outcome: .failure)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .hFormTitle(
            title: .init(.small, .body1, title, alignment: .leading),
            subTitle: subtitle.map { .init(.small, .body1, $0, alignment: .leading) }
        )
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            bottomContent
        }
        .task {
            if await vm.pollUntilSettled() {
                await onConnected()
            }
        }
    }

    private var bottomContent: some View {
        hSection {
            VStack(spacing: .padding16) {
                hText(L10n.paymentChangeFootnote, style: .label)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .multilineTextAlignment(.center)
                VStack(spacing: .padding8) {
                    primaryButton
                    cancelButton
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    /// Waiting has nothing to offer a member without Swish installed — the consent is approved
    /// in the app, and polling carries on regardless — so cancelling is the only action left.
    @ViewBuilder
    private var primaryButton: some View {
        switch vm.state {
        case .waiting:
            if vm.canOpenSwish {
                hButton(.large, .primary, content: .init(title: L10n.paymentOpenSwishButton)) {
                    await vm.reopenSwish()
                }
            }
        case .failed:
            hButton(.large, .primary, content: .init(title: L10n.generalRetry)) {
                if await vm.tryAgain() {
                    await onConnected()
                }
            }
            .hButtonIsLoading(vm.isRetrying)
        }
    }

    private var cancelButton: some View {
        hButton(.large, cancelButtonType, content: .init(title: secondaryTitle)) {
            router.dismiss()
        }
    }

    /// Cancel is promoted to the primary slot when no other action is offered.
    private var cancelButtonType: hButtonConfigurationType {
        switch vm.state {
        case .waiting: vm.canOpenSwish ? .ghost : .primary
        case .failed: .ghost
        }
    }

    private var title: String {
        switch vm.state {
        case .waiting: L10n.paymentSwishApproveTitle
        case .failed: L10n.paymentSwishFailureTitle
        }
    }

    private var subtitle: String? {
        switch vm.state {
        case .waiting: nil
        case let .failed(error): error ?? L10n.somethingWentWrong
        }
    }

    private var secondaryTitle: String {
        switch vm.state {
        case .waiting: L10n.generalCancelButton
        case .failed: L10n.paymentChangeMethodButton
        }
    }
}

@MainActor
class SwishPayinConsentViewModel: ObservableObject {
    @Published var state: SwishConsentState
    @Published var isRetrying = false
    @Published private(set) var qrImage: UIImage?

    /// Resolved once per presentation rather than per render: `canOpenURL` is a system call,
    /// and a member who leaves to install Swish comes back to a freshly built screen.
    let canOpenSwish: Bool

    private let phoneNumber: String
    private var orderId: String?
    private var url: String? {
        didSet { qrImage = Self.generateQRImage(from: url) }
    }
    private let paymentService = hPaymentService()

    private let pollInterval: TimeInterval
    private let pollTimeout: TimeInterval

    init(
        phoneNumber: String,
        orderId: String?,
        url: String?,
        state: SwishConsentState,
        pollInterval: TimeInterval = 2,
        pollTimeout: TimeInterval = 120
    ) {
        self.canOpenSwish = SwishDeepLink.canOpen
        self.phoneNumber = phoneNumber
        self.orderId = orderId
        self.url = url
        self.state = state
        self.pollInterval = pollInterval
        self.pollTimeout = pollTimeout
        // `didSet` doesn't fire during init, so seed the first code by hand.
        self.qrImage = Self.generateQRImage(from: url)
    }

    private static func generateQRImage(from url: String?) -> UIImage? {
        url.flatMap(SwishQRCode.image(for:))
    }

    func reopenSwish() async {
        await SwishDeepLink.open(url)
    }

    func pollUntilSettled() async -> Bool {
        guard state == .waiting, let orderId else { return false }
        let deadline = Date().addingTimeInterval(pollTimeout)

        while state == .waiting, Date() < deadline {
            do {
                try await Task.sleep(for: .seconds(pollInterval))
            } catch {
                return false  // the screen went away
            }
            do {
                let status = try await paymentService.getPaymentSetupStatus(orderId: orderId)
                switch status {
                case .active:
                    return true
                case .failed:
                    withAnimation { state = .failed(error: nil) }
                    return false
                case .pending, .unknown:
                    continue
                }
            } catch {
                withAnimation { state = .failed(error: error.localizedDescription) }
                return false
            }
        }

        if state == .waiting {
            withAnimation { state = .failed(error: nil) }
        }
        return false
    }

    func tryAgain() async -> Bool {
        withAnimation {
            isRetrying = true
            state = .waiting
        }

        do {
            let result = try await paymentService.setupPaymentMethod(.swishPayin(phoneNumber: phoneNumber))
            orderId = result.orderId
            url = result.url
            // The waiting layout takes over from here, so stop showing the button as loading.
            withAnimation { isRetrying = false }

            if result.status == .failed || result.errorMessage != nil {
                withAnimation { state = .failed(error: result.errorMessage) }
                return false
            }
            if result.status == .active {
                return true
            }
        } catch {
            withAnimation {
                isRetrying = false
                state = .failed(error: error.localizedDescription)
            }
            return false
        }
        return await pollUntilSettled()
    }
}

/// QR with a matching monochrome Swish logo in the cleared centre — black in light mode, white in dark mode.
private struct SwishQRCodeView: View {
    let image: UIImage

    var body: some View {
        GeometryReader { proxy in
            Image(uiImage: image)
                .resizable()
                .overlay {
                    hCoreUIAssets.swish.view
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: proxy.size.width * SwishQRCode.logoFraction * 0.8)
                }
                .foregroundColor(
                    hTextColor.Opaque.primary
                )
        }
    }
}

/// Draws a QR code in the Swish style — round modules, rounded finder patterns and an empty centre for
/// the logo — as a template image, so the caller decides the fill.
enum SwishQRCode {
    /// Share of the code's width left empty in the middle for the logo.
    static let logoFraction: CGFloat = 0.24

    private static let moduleSize: CGFloat = 12
    private static let finderSize = 7
    private static let ciContext = CIContext()

    static func image(for message: String) -> UIImage? {
        guard let modules = modules(for: message) else { return nil }
        let count = modules.count
        let finderOrigins = [
            (column: 0, row: 0),
            (column: count - finderSize, row: 0),
            (column: 0, row: count - finderSize),
        ]
        let logo = logoRange(count: count)

        /// Modules covered by a finder pattern or the logo are left to those instead.
        func isCovered(column: Int, row: Int) -> Bool {
            let inFinder = finderOrigins.contains {
                ($0.column..<$0.column + finderSize).contains(column) && ($0.row..<$0.row + finderSize).contains(row)
            }
            return inFinder || (logo.contains(column) && logo.contains(row))
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 2
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
    /// High error correction leaves room for the modules cleared under the logo.
    private static func modules(for message: String) -> [[Bool]]? {
        guard let data = message.data(using: .utf8) else { return nil }
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "H"
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
    private static func logoRange(count: Int) -> Range<Int> {
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

@MainActor
private func previewScreen(_ state: SwishConsentState) -> some View {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    return SwishPayinConsentScreen(phoneNumber: "0709901232", orderId: nil, url: "https://www.google.com", state: state)
        .environmentObject(NavigationRouter())
}

#Preview("Waiting") { previewScreen(.waiting) }

#Preview("Failed") { previewScreen(.failed(error: nil)) }
