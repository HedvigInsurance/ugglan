import SwiftUI
import hCore
import hCoreUI

struct SwishPayinSetupScreen: View {
    private let phoneNumber: String?
    private let onSuccess: (() async -> Void)?
    @StateObject private var router = NavigationRouter()

    init(phoneNumber: String? = nil, onSuccess: (() async -> Void)? = nil) {
        self.phoneNumber = phoneNumber
        self.onSuccess = onSuccess
    }

    var body: some View {
        SwishPayinPhoneNumberScreen(phoneNumber: phoneNumber, onSuccess: onSuccess)
            .routerDestination(for: SwishPayinRoute.self) { route in
                switch route {
                case let .consent(phoneNumber, orderId, url):
                    SwishPayinConsentScreen(
                        phoneNumber: phoneNumber,
                        orderId: orderId,
                        url: url,
                        onConnected: { await onSuccess?() }
                    )
                    .withDismissButton()
                }
            }
            .withDismissButton()
            .embededInNavigation(router: router, tracking: SwishPayinSetupTracking.setup)
    }
}

enum SwishPayinRoute: Hashable, TrackingViewNameProtocol {
    case consent(phoneNumber: String, orderId: String?, url: String?)

    var nameForTracking: String {
        switch self {
        case .consent:
            return .init(describing: SwishPayinConsentScreen.self)
        }
    }
}

private enum SwishPayinSetupTracking: TrackingViewNameProtocol {
    case setup

    var nameForTracking: String {
        switch self {
        case .setup:
            return .init(describing: SwishPayinSetupScreen.self)
        }
    }
}

private struct SwishPayinPhoneNumberScreen: View {
    @StateObject private var vm = SwishPayinSetupViewModel()
    @EnvironmentObject private var router: NavigationRouter
    @State private var showsExplanation = false
    let phoneNumber: String?
    let onSuccess: (() async -> Void)?

    var body: some View {
        hForm {
            SwishPillow()
        }
        .hFormTitle(
            title: .init(.small, .body1, L10n.paymentSwishTitle, alignment: .leading),
            subTitle: .init(.small, .body1, L10n.paymentSwishSubtitle, alignment: .leading)
        )
        .hFormContentPosition(.center)
        .hFormAttachToBottom {
            bottomContent
        }
        .disabled(vm.isLoading)
        .onAppear { vm.prefill(phoneNumber: phoneNumber) }
        .detent(presented: $showsExplanation, options: .constant(.withoutGrabber)) {
            SwishExplanationScreen()
        }
    }

    private var bottomContent: some View {
        VStack(spacing: 0) {
            helpLink
                .padding(.bottom, .padding16)
            hSection {
                phoneNumberField
            }
            .sectionContainerStyle(.transparent)
            hSection {
                VStack(spacing: .padding8) {
                    if let errorMessage = vm.errorMessage {
                        PaymentErrorLabel(message: errorMessage)
                    }
                    confirmButton
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
        }
    }

    /// A line of 14pt text is nowhere near a 44pt touch target on its own, so the label carries
    /// the padding and the minimum height — putting them on the button would leave the hit area
    /// the size of the text.
    private var helpLink: some View {
        SwiftUI.Button {
            showsExplanation = true
        } label: {
            hText(L10n.paymentSwishExplanationButton, style: .label)
                .foregroundColor(hTextColor.Translucent.secondary)
                .underline()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, .padding16)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
        }
        .accessibilityHint(L10n.paymentSwishExplanationButton)
    }

    private var phoneNumberField: some View {
        hFloatingTextField(
            masking: .init(type: .phoneNumber),
            value: $vm.phoneNumber,
            equals: $vm.focusedField,
            focusValue: .phoneNumber,
            placeholder: L10n.phoneNumberRowTitle,
            error: $vm.phoneNumberError
        )
    }

    /// A pending consent lands on the waiting screen even when the deep link can't open — an
    /// unopenable link still needs somewhere to retry from.
    private var confirmButton: some View {
        hButton(
            .large,
            .primary,
            content: .init(title: L10n.generalConfirm)
        ) {
            guard let result = await vm.save() else { return }
            if result.status == .active {
                await onSuccess?()
            } else {
                // Swish is where the consent is actually approved, so go there first when it
                // is installed; the waiting screen is what the member comes back to.
                if SwishDeepLink.canOpen {
                    await SwishDeepLink.open(result.url)
                }
                router.push(
                    SwishPayinRoute.consent(
                        phoneNumber: vm.unmaskedPhoneNumber,
                        orderId: result.orderId,
                        url: result.url
                    )
                )
            }
        }
        .hButtonIsLoading(vm.isLoading)
    }
}

@MainActor
class SwishPayinSetupViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var focusedField: SwishPayinField?
    @Published var phoneNumberError: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let paymentService = hPaymentService()
    private let phoneNumberMasking = Masking(type: .phoneNumber)

    var unmaskedPhoneNumber: String {
        phoneNumberMasking.unmaskedValue(text: phoneNumber)
    }

    /// Fills the field the first time only — a member who has already edited it keeps what
    /// they typed.
    func prefill(phoneNumber: String?) {
        guard let phoneNumber, !phoneNumber.isEmpty, self.phoneNumber.isEmpty else { return }
        self.phoneNumber = phoneNumber
    }

    func save() async -> PaymentSetupResult? {
        withAnimation {
            phoneNumberError = nil
            errorMessage = nil
        }

        if !validate() { return nil }

        withAnimation { isLoading = true }
        defer { withAnimation { isLoading = false } }

        do {
            let result = try await paymentService.setupPaymentMethod(
                .swishPayin(phoneNumber: unmaskedPhoneNumber)
            )
            if result.status == .failed || result.errorMessage != nil {
                withAnimation { errorMessage = result.errorMessage ?? L10n.General.errorBody }
                return nil
            }
            return result
        } catch {
            withAnimation { errorMessage = error.localizedDescription }
            return nil
        }
    }

    private func validate() -> Bool {
        guard phoneNumberMasking.isValid(text: phoneNumber) else {
            withAnimation {
                phoneNumberError = L10n.myInfoPhoneNumberMalformedError
                focusedField = .phoneNumber
            }
            return false
        }
        return true
    }
}

enum SwishPayinField: hTextFieldFocusStateCompliant {
    case phoneNumber

    static var last: SwishPayinField { .phoneNumber }

    var next: SwishPayinField? {
        switch self {
        case .phoneNumber: return nil
        }
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    return SwishPayinSetupScreen(phoneNumber: "0735328847")
}
