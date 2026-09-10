import CoreImage
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
                        Image(uiImage: qrImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 140)
                            .foregroundColor(hTextColor.Opaque.primary)
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

    /// Renders the Swish deep link as a template image so it picks up the current text colour.
    private static func generateQRImage(from url: String?) -> UIImage? {
        guard let data = url?.data(using: .ascii) else { return nil }
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        guard let qrImage = qrFilter.outputImage else { return nil }

        let scaledQrImage = qrImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))

        guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        maskToAlphaFilter.setValue(scaledQrImage, forKey: "inputImage")
        guard let outputCIImage = maskToAlphaFilter.outputImage else { return nil }

        let context = CIContext()
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        return UIImage(cgImage: cgImage).withRenderingMode(.alwaysTemplate)
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

@MainActor
private func previewScreen(_ state: SwishConsentState) -> some View {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    return SwishPayinConsentScreen(phoneNumber: "0709901232", orderId: nil, url: "https://www.google.com", state: state)
        .environmentObject(NavigationRouter())
}

#Preview("Waiting") { previewScreen(.waiting) }

#Preview("Failed") { previewScreen(.failed(error: nil)) }
