import Environment
import SwiftUI
import hCore
import hCoreUI

/// No success case: an approved consent closes the Swish flow rather than rendering a screen.
enum SwishConsentState: Equatable {
    case loading
    /// Showing the code, with nobody sent anywhere yet.
    case waiting
    /// The member has left for Swish, so the code has served its purpose.
    case approving
    case failed(error: String?)

    /// Waiting and approving are the same wait — an approval in Swish — and differ only in what
    /// the screen shows while it runs, so polling spans both.
    var isAwaitingApproval: Bool {
        switch self {
        case .waiting, .approving: true
        case .loading, .failed: false
        }
    }
}

struct SwishPayinConsentScreen: View {
    /// Side of the QR code, held by the loading indicator too so the sheet doesn't resize when
    /// the code lands.
    private static let codeSide: CGFloat = 180
    @SwiftUI.Environment(\.verticalSizeClass) var verticalSizeClass

    @StateObject private var vm: SwishPayinConsentViewModel
    @StateObject private var router = NavigationRouter()
    @State private var showsExplanation = false
    /// Opened from a method picker, so a failure can send the member back to pick another.
    private let canChangeMethod: Bool
    private let onConnected: () async -> Void

    init(
        state: SwishConsentState = .loading,
        canChangeMethod: Bool = false,
        onConnected: @escaping () async -> Void = {}
    ) {
        _vm = StateObject(wrappedValue: SwishPayinConsentViewModel(state: state))
        self.canChangeMethod = canChangeMethod
        self.onConnected = onConnected
    }

    /// Navigation carries nothing here — no screen is pushed — but it is what reports the view
    /// name, so the bar is hidden rather than the stack dropped.
    var body: some View {
        content
            .embededInNavigation(
                router: router,
                options: .navigationBarHidden,
                tracking: SwishPayinConsentTracking.consent
            )
    }

    private var content: some View {
        hForm {
            ZStack {
                Rectangle()
                    .fill(.clear)
                    .frame(width: 0, height: verticalSizeClass == .compact ? 100 : 300)
                VStack(spacing: .padding32) {
                    graphic
                }
                .fixedSize(horizontal: true, vertical: true)
            }
        }
        .hFormTitle(
            title: .init(.navigationLike, .body1, title, alignment: .center),
            subTitle: subtitle.map { .init(.navigationLike, .body1, $0, alignment: .center) }
        )
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            bottomContent
        }
        .task(id: vm.pollAttempt) {
            if await vm.connect() {
                await onConnected()
            }
        }
        .detent(presented: $showsExplanation, options: .constant(.withoutGrabber)) {
            SwishExplanationScreen()
        }
        .onChange(of: vm.state) { newState in
            announce(newState)
        }
    }

    /// Nothing visibly moves when the order lands — the title is unchanged and the QR code is
    /// hidden from VoiceOver — so each settled state is spoken instead.
    private func announce(_ state: SwishConsentState) {
        let message: String
        switch state {
        case .loading, .approving:
            return
        case .waiting:
            message = L10n.paymentSwishApproveTitle
        case let .failed(error):
            message = L10n.paymentSwishFailureTitle + ". " + (error ?? L10n.somethingWentWrong)
        }
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    @ViewBuilder
    private var graphic: some View {
        switch vm.state {
        case .loading:
            DotsActivityIndicator(.standard)
                .useDarkColor
                .frame(width: Self.codeSide, height: Self.codeSide)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(L10n.embarkLoading)
                .accessibilityAddTraits(.updatesFrequently)
        case .waiting:
            if let qrImage = vm.qrImage {
                StyledQRCodeView(image: qrImage) {
                    hCoreUIAssets.swish.view
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(width: Self.codeSide, height: Self.codeSide)
                .accessibilityHidden(true)

                if vm.canOpenSwish {
                    DotsActivityIndicator(.standard)
                        .useDarkColor
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(L10n.embarkLoading)
                        .accessibilityAddTraits(.updatesFrequently)
                }
            }
        // One branch, so the graphic stays mounted and its badge animates in rather than the
        // whole thing being rebuilt when the connection fails.
        case .approving, .failed:
            PaymentConnectionGraphic(provider: .swish, outcome: connectionOutcome)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(L10n.embarkLoading)
                .accessibilityAddTraits(.updatesFrequently)
                // Settled: the title and subtitle carry the outcome, so the graphic is decoration.
                .accessibilityHidden(connectionOutcome != nil)
        }
    }

    /// `nil` while the connection is still in flight, which is what keeps the graphic animating.
    private var connectionOutcome: StatusBadge.Kind? {
        if case .failed = vm.state { return .failure }
        return nil
    }

    private var bottomContent: some View {
        hSection {
            VStack(spacing: .padding16) {
                helpLink
                VStack(spacing: .padding8) {
                    primaryButton
                    cancelButton
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private var helpLink: some View {
        SwiftUI.Button {
            showsExplanation = true
        } label: {
            hText(L10n.paymentSwishExplanationButton, style: .label)
                .foregroundColor(hTextColor.Translucent.secondary)
                .underline()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
        }
    }

    /// Waiting has nothing to offer a member without Swish installed — they approve the consent
    /// by scanning the QR code elsewhere, and polling carries on regardless — so cancelling is
    /// the only action left. Fetching offers nothing at all until it settles.
    @ViewBuilder
    private var primaryButton: some View {
        switch vm.state {
        case .loading, .approving:
            EmptyView()
        case .waiting:
            if vm.canOpenSwish {
                hButton(.large, .primary, content: .init(title: L10n.paymentOpenSwishButton)) {
                    await vm.openSwish()
                }
            }
        case .failed:
            hButton(.large, .primary, content: .init(title: L10n.generalRetry)) {
                await vm.requestNewOrder()
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
        case .loading, .approving: .primary
        case .waiting: vm.canOpenSwish ? .ghost : .primary
        case .failed: .ghost
        }
    }

    private var title: String {
        switch vm.state {
        case .loading, .waiting, .approving: L10n.paymentSwishApproveTitle
        case .failed: L10n.paymentSwishFailureTitle
        }
    }

    private var subtitle: String? {
        switch vm.state {
        case .loading, .waiting, .approving: nil
        case let .failed(error): error ?? L10n.somethingWentWrong
        }
    }

    private var secondaryTitle: String {
        switch vm.state {
        case .loading, .waiting, .approving: L10n.generalCancelButton
        case .failed: canChangeMethod ? L10n.paymentChangeMethodButton : L10n.generalCloseButton
        }
    }
}

private enum SwishPayinConsentTracking: TrackingViewNameProtocol {
    case consent

    var nameForTracking: String {
        switch self {
        case .consent:
            return .init(describing: SwishPayinConsentScreen.self)
        }
    }
}

@MainActor
class SwishPayinConsentViewModel: ObservableObject {
    @Published var state: SwishConsentState
    @Published var isRetrying = false
    @Published private(set) var qrImage: UIImage?
    @Published private(set) var pollAttempt = 0
    /// Resolved once per presentation rather than per render: `canOpenURL` is a system call,
    /// and a member who leaves to install Swish comes back to a freshly built screen.
    let canOpenSwish: Bool

    private var orderId: String?
    private var url: String? {
        didSet { qrImage = Self.generateQRImage(from: url) }
    }
    private let paymentService = hPaymentService()

    private let pollInterval: TimeInterval

    /// `orderId` and `url` seed a screen that already has an order, for previews and tests. The
    /// flow itself starts empty and fetches one.
    init(
        orderId: String? = nil,
        url: String? = nil,
        state: SwishConsentState = .loading,
        pollInterval: TimeInterval = 2
    ) {
        self.canOpenSwish = SwishDeepLink.canOpen
        self.orderId = orderId
        self.url = url
        self.state = state
        self.pollInterval = pollInterval
        // `didSet` doesn't fire during init, so seed the first code by hand.
        self.qrImage = Self.generateQRImage(from: url)
    }

    private static func generateQRImage(from url: String?) -> UIImage? {
        url.flatMap { StyledQRCode.image(for: $0) }
    }

    /// One pass of the flow: fetch an order when the screen hasn't got one, then wait for the
    /// member to approve it. Returns true once the payment method is connected.
    func connect() async -> Bool {
        if state == .loading {
            let connected = await requestFirstOrder()
            if connected { return true }
        }
        return await pollUntilSettled()
    }

    /// Fetches an order and stores it, parking the screen on a failure. Returns the status while
    /// there is still something to wait for, and nil once the screen has been failed.
    private func requestOrder() async -> PaymentSetupResult.PaymentSetupStatus? {
        do {
            let result = try await paymentService.setupPaymentMethod(.swishPayin)
            orderId = result.orderId
            url = result.url

            if result.status == .failed || result.errorMessage != nil {
                withAnimation { state = .failed(error: result.errorMessage) }
                return nil
            }
            return result.status
        } catch {
            withAnimation { state = .failed(error: error.localizedDescription) }
            return nil
        }
    }

    /// Returns true when setup came back already connected, which leaves nothing to wait for
    /// and no order to poll.
    private func requestFirstOrder() async -> Bool {
        guard let status = await requestOrder() else { return false }
        if status == .active { return true }

        withAnimation { state = .waiting }
        return false
    }

    /// Leaving for Swish is always the member's own tap, and the button stays put afterwards:
    /// an app switch that doesn't take needs somewhere to try again from.
    func openSwish() async {
        withAnimation { state = .approving }
        let returnUrl = Environment.current.deepLinkUrl.absoluteString
            .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        var swishComponents = url.flatMap(URLComponents.init(string:))
        let existingQueryItems = swishComponents?.percentEncodedQueryItems ?? []
        swishComponents?.percentEncodedQueryItems = existingQueryItems + [URLQueryItem(name: "ret", value: returnUrl)]
        let swishUrl = swishComponents?.url?.absoluteString
        await SwishDeepLink.open(swishUrl)
    }

    /// Waits for as long as the screen is up: approving in Swish is the member's own errand and
    /// has no deadline of ours, so the only way out other than a settled order is the task being
    /// cancelled when the screen goes away.
    func pollUntilSettled() async -> Bool {
        guard state.isAwaitingApproval, let orderId else { return false }

        while state.isAwaitingApproval {
            do {
                let status = try await paymentService.getPaymentSetupStatus(orderId: orderId)
                switch status {
                case .active:
                    return true
                case .failed:
                    withAnimation { state = .failed(error: nil) }
                    return false
                case .pending, .unknown:
                    break
                }
            } catch {
                withAnimation { state = .failed(error: error.localizedDescription) }
                return false
            }
            do {
                try await Task.sleep(for: .seconds(pollInterval))
            } catch {
                return false  // cancelled: the screen went away
            }
        }

        return false
    }

    /// Re-arms the view's task so the new order gets polled.
    func requestNewOrder() async {
        withAnimation { isRetrying = true }
        defer { withAnimation { isRetrying = false } }

        guard await requestOrder() != nil else { return }
        // Back to `.waiting`: a new order means a new code the member hasn't used yet, and one
        // that came back already active settles on the re-armed task's first poll.
        withAnimation { state = .waiting }
        pollAttempt += 1
    }
}

@MainActor
private func previewScreen(_ state: SwishConsentState) -> some View {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    return SwishPayinConsentScreen(state: state)
}

#Preview("Loading") { previewScreen(.loading) }

#Preview("Waiting") { previewScreen(.waiting) }

#Preview("Approving") { previewScreen(.approving) }

#Preview("Failed") { previewScreen(.failed(error: nil)) }
