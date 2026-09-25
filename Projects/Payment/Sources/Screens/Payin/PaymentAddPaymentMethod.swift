import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

public struct PaymentAddPaymentMethod: View {
    public struct Heading {
        let title: String
        let subTitle: String
        let alignment: Alignment

        public init(title: String, subTitle: String, alignment: Alignment = .center) {
            self.title = title
            self.subTitle = subTitle
            self.alignment = alignment
        }
    }

    @AppObservedObject var store: PaymentStore
    @Environment(\.dismiss) private var dismiss

    @State private var selected: PaymentProvider?
    @State private var providerToSetUp: PaymentProvider?
    @State private var connectedProvider: PaymentProvider?

    private let heading: Heading?
    private let phoneNumber: String?
    private let onFinished: ((_ provider: PaymentProvider) -> Void)?

    public init() {
        self.heading = nil
        self.phoneNumber = nil
        self.onFinished = nil
    }

    public init(
        heading: Heading,
        phoneNumber: String? = nil,
        connectedProvider: PaymentProvider? = nil,
        onFinished: @escaping (_ provider: PaymentProvider) -> Void
    ) {
        self.heading = heading
        self.phoneNumber = phoneNumber
        self.onFinished = onFinished
        _connectedProvider = State(initialValue: connectedProvider)
    }

    private var prefilledPhoneNumber: String? {
        phoneNumber ?? store.paymentStatusData?.memberPhoneNumber
    }

    private var isHostedInFlow: Bool {
        onFinished != nil
    }

    public var body: some View {
        hForm {
            formContent
        }
        .hFormAttachToBottom {
            bottomContent
        }
        .hFormTitle(title: formTitle, subTitle: formSubTitle)
        .handlePaymentSetup(for: $providerToSetUp, phoneNumber: prefilledPhoneNumber) { provider in
            withAnimation { connectedProvider = provider }
        }
        .task {
            // The picker lists what the backend offers, so a host that opens this screen
            // without having loaded the status has nothing to show until it is fetched.
            // Opening straight on the confirmation needs none of it.
            if connectedProvider == nil, store.paymentStatusData == nil {
                await store.fetchPaymentStatus()
            }
        }
    }

    @ViewBuilder
    private var formContent: some View {
        if let provider = connectedProvider {
            PaymentConnectionPairGraphic(provider: provider, outcome: .success)
                .padding(.vertical, .padding96)
        } else {
            PaymentMethodPickerGraphic(selected: selected)
                .padding(.vertical, .padding64)
        }
    }

    @ViewBuilder
    private var bottomContent: some View {
        if let connectedProvider {
            confirmationContent(for: connectedProvider)
        } else {
            pickerContent
        }
    }

    @ViewBuilder
    private var pickerContent: some View {
        if let methods = store.paymentStatusData?.availablePayinMethods {
            hSection {
                hRadioOptionList(methods, id: \.provider, spacing: .padding8) { method in
                    PaymentMethodRow(payin: method.provider, selection: $selected)
                }
            }
            .sectionContainerStyle(.transparent)
        }
        hSection {
            VStack(spacing: .padding8) {
                hButton(.large, .primary, content: .init(title: L10n.paymentConnectTitle)) {
                    providerToSetUp = selected
                }
                .disabled(selected == nil)
                if !isHostedInFlow {
                    hButton(.large, .ghost, content: .init(title: L10n.generalCancelButton)) {
                        dismiss()
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private func confirmationContent(for provider: PaymentProvider) -> some View {
        VStack(spacing: .padding16) {
            hText(L10n.paymentChangeFootnote, style: .label)
                .foregroundColor(hTextColor.Translucent.secondary)
                .multilineTextAlignment(.center)
            hSection {
                hButton(.large, .primary, content: .init(title: L10n.generalContinueButton)) {
                    finish(with: provider)
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    private func finish(with provider: PaymentProvider) {
        if let onFinished {
            onFinished(provider)
        } else {
            dismiss()
        }
    }

    private var headingAlignment: Alignment {
        heading?.alignment ?? .center
    }

    private var formTitle: hTitle {
        if let connectedProvider {
            return title(connectedTitle(for: connectedProvider))
        }
        return title(heading?.title ?? L10n.paymentConnectTitle)
    }

    private var formSubTitle: hTitle {
        if connectedProvider == .swish {
            return title(L10n.paymentSwishSuccessSubtitle)
        }
        if connectedProvider != nil {
            return title(L10n.paymentTrustlySuccessSubtitle)
        }
        return title(heading?.subTitle ?? L10n.paymentConnectSubtitle)
    }

    private func title(_ text: String) -> hTitle {
        .init(.small, .body1, text, alignment: headingAlignment)
    }

    private func connectedTitle(for provider: PaymentProvider) -> String {
        if provider == .swish {
            return L10n.paymentSwishSuccessTitle
        }
        return "\(provider.payinTitle) \(L10n.paymentOptionConnectedLabel)"
    }
}

@MainActor
private func setUpPreviewStore() {
    let store: PaymentStore = globalAppStateContainer.get()
    store.paymentStatusData = .init(
        status: .needsSetup,
        chargingDay: 27,
        defaultPayinMethod: nil,
        payinMethods: [],
        defaultPayoutMethod: nil,
        payoutMethods: [],
        availableMethods: [
            .init(provider: .trustly, supportsPayin: true, supportsPayout: true),
            .init(provider: .swish, supportsPayin: true, supportsPayout: true),
            .init(provider: .invoice, supportsPayin: true, supportsPayout: false),
        ],
        missingConnection: .payin,
        layout: .other,
        memberPhoneNumber: "0735328847"
    )
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
}

#Preview("Pick a method") {
    setUpPreviewStore()
    return PaymentAddPaymentMethod()
}

#Preview("Hosted by a flow") {
    setUpPreviewStore()
    return PaymentAddPaymentMethod(
        heading: .init(
            title: "Connect payment",
            subTitle: "Set up how you want to pay",
            alignment: .leading
        ),
        onFinished: { _ in }
    )
}
