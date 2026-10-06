import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

public struct AddPaymentMethodScreen: View {
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
    private let confirmationFootnote: String?
    private let onFinished: ((_ provider: PaymentProvider) -> Void)?

    public init() {
        self.heading = nil
        self.onFinished = nil
        self.confirmationFootnote = nil
    }

    public init(
        heading: Heading? = nil,
        connectedProvider: PaymentProvider? = nil,
        confirmationFootnote: String?,
        onFinished: @escaping (_ provider: PaymentProvider) -> Void
    ) {
        self.heading = heading
        self.onFinished = onFinished
        self.confirmationFootnote = confirmationFootnote
        _connectedProvider = State(initialValue: connectedProvider)
    }

    private var isHostedInFlow: Bool {
        onFinished != nil
    }

    public var body: some View {
        PaymentConnectFlowView(
            direction: .payin,
            methods: store.paymentStatusData?.availablePayinMethods ?? [],
            title: formTitle,
            subTitle: formSubTitle,
            connectTitle: L10n.paymentConnectTitle,
            confirmationFootnote: confirmationFootnote,
            selected: $selected,
            connectedProvider: connectedProvider,
            onConnect: { providerToSetUp = selected },
            onCancel: isHostedInFlow ? nil : { dismiss() },
            onContinue: { connectedProvider.map(finish(with:)) }
        )
        .animation(.default, value: selected)
        .handlePayinSetup(
            for: $providerToSetUp,
            canChangeMethod: true,
            completion: .custom { provider in
                withAnimation { connectedProvider = provider }
            }
        )
        .task {
            // The picker lists what the backend offers, so a host that opens this screen
            // without having loaded the status has nothing to show until it is fetched.
            // Opening straight on the confirmation needs none of it.
            if connectedProvider == nil, store.paymentStatusData == nil {
                await store.fetchPaymentStatus()
            }
        }
    }

    private func finish(with provider: PaymentProvider) {
        if let onFinished {
            onFinished(provider)
        } else {
            dismiss()
        }
    }

    private var formTitle: hTitle {
        title(connectedProvider.map(connectedTitle(for:)) ?? heading?.title ?? L10n.paymentConnectTitle)
    }

    private var formSubTitle: hTitle {
        guard let connectedProvider else {
            return title(heading?.subTitle ?? L10n.paymentConnectSubtitle)
        }
        return title(
            connectedProvider == .swish ? L10n.paymentSwishSuccessSubtitle : L10n.paymentTrustlySuccessSubtitle
        )
    }

    private func title(_ text: String) -> hTitle {
        .init(heading == nil ? .navigationLike : .small, .body1, text, alignment: heading?.alignment ?? .center)
    }

    private func connectedTitle(for provider: PaymentProvider) -> String {
        switch provider {
        case .trustly:
            L10n.PayInConfirmationDirectDebit.headline
        case .swish:
            L10n.paymentSwishSuccessTitle
        default:
            "\(provider.payinTitle) \(L10n.paymentOptionConnectedLabel)"
        }
    }
}

extension View {
    public func handleAddPaymentMethod(presented: Binding<Bool>) -> some View {
        detent(
            presented: presented,
            presentationStyle: .detent(style: [.height]),
            options: .constant(.alwaysOpenOnTop)
        ) {
            AddPaymentMethodScreen()
                .hFormContentPosition(.compact)
        }
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
        layout: .other
    )
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
}

#Preview("Pick a method") {
    setUpPreviewStore()
    return AddPaymentMethodScreen()
}

#Preview("Hosted by a flow") {
    setUpPreviewStore()
    return AddPaymentMethodScreen(
        heading: .init(
            title: "Connect payment",
            subTitle: "Set up how you want to pay",
            alignment: .leading
        ),
        confirmationFootnote: nil,
        onFinished: { _ in }
    )
}
