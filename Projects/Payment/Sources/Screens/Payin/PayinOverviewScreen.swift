import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct PayinOverviewScreen: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var vm = PayinOverviewViewModel()

    public init() {}

    public var body: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { $0.paymentStatusData }
        ) { paymentStatusData in
            if let paymentStatusData {
                content(paymentStatusData: paymentStatusData)
            }
        }
    }

    @ViewBuilder
    private func content(paymentStatusData: PaymentStatusData) -> some View {
        let currentMethods = paymentStatusData.payinMethods
        let availablePayinMethods = paymentStatusData.availablePayinMethods

        hForm {
            VStack(spacing: .padding16) {
                if currentMethods.isEmpty {
                    if !availablePayinMethods.isEmpty {
                        emptyMethodsView
                    } else {
                        noOptionsView
                    }
                } else {
                    methodsList(currentMethods: currentMethods)
                }
            }
            .padding(.top, .padding16)
        }
        .hFormAttachToBottom {
            VStack(spacing: .padding16) {
                if let errorMessage = vm.setDefaultProviderError {
                    hSection {
                        InfoCard(text: errorMessage, type: .error)
                    }
                    .sectionContainerStyle(.transparent)
                }
                if currentMethods.contains(where: { $0.status == .pending }) {
                    hSection {
                        InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
                    }
                    .sectionContainerStyle(.transparent)
                }
                if !availablePayinMethods.isEmpty {
                    hSection {
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: "Add payin method")  //L10n.payinAddPayinMethod
                        ) { [weak router] in
                            router?.push(PayinRouterActions.changePayinMethod)
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
        }
    }

    private var emptyMethodsView: some View {
        hSection {
            VStack(spacing: .padding16) {
                hCoreUIAssets.infoFilled.view
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hSignalColor.Blue.element)
                hText("You haven't added a payin method yet")  //L10n.payinMissingInfo
                    .multilineTextAlignment(.center)
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private var noOptionsView: some View {
        hSection {
            VStack(spacing: .padding16) {
                hCoreUIAssets.infoFilled.view
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hSignalColor.Blue.element)
                VStack(spacing: .padding2) {
                    hText("No payin method available")  //L10n.payinNoPayinOptionsTitle
                        .multilineTextAlignment(.center)
                    hText("Contact us to set up a payin method")  //L10n.payinNoPayinOptionsSubtitle
                        .multilineTextAlignment(.center)
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private func methodsList(currentMethods: [PaymentMethodData]) -> some View {
        VStack(spacing: .padding8) {
            ForEach(currentMethods) { method in
                PayinMethodRow(
                    method: method,
                    isLoading: vm.loadingDefaultProvider == method.provider,
                    onSetAsDefault: { [weak vm] in
                        await vm?.setAsDefault(provider: method.provider)
                    }
                )
            }
        }
    }
}

private struct PayinMethodRow: View {
    let method: PaymentMethodData
    let isLoading: Bool
    let onSetAsDefault: () async -> Void

    var body: some View {
        hSection {
            hRow {
                VStack(alignment: .leading, spacing: .padding4) {
                    hText(rowLabel)
                    hText(rowValue, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
                Spacer()
                trailingView
            }
        }
    }

    private var rowLabel: String {
        method.provider.payinTitle
    }

    private var rowValue: String {
        if method.status == .pending, methodDetailValue.isEmpty {
            return L10n.referralPendingStatusLabel
        }
        return methodDetailValue
    }

    private var methodDetailValue: String {
        switch method.details {
        case let .bankAccount(account, bank):
            return "\(bank) \(account)"
        case let .swish(phoneNumber):
            return phoneNumber
        case let .invoice(delivery, _):
            switch delivery {
            case .kivra: return "Kivra"
            case .mail: return "Email"
            case .unknown: return ""
            }
        case nil:
            return ""
        }
    }

    @ViewBuilder
    private var trailingView: some View {
        if method.isDefault {
            hPill(
                text: "Default",  //L10n.payinDefaultBadge
                color: .green
            )
            .hFieldSize(.small)
        } else if method.status != .pending {
            hButton(
                .small,
                .secondary,
                content: .init(title: "Choose as default")  //L10n.payinChooseAsDefault
            ) {
                Task { await onSetAsDefault() }
            }
            .hButtonIsLoading(isLoading)
        }
    }
}

@MainActor
class PayinOverviewViewModel: ObservableObject {
    @Published var loadingDefaultProvider: PaymentProvider?
    @Published var setDefaultProviderError: String?

    private let paymentService = hPaymentService()

    func setAsDefault(provider: PaymentProvider) async {
        setDefaultProviderError = nil
        loadingDefaultProvider = provider
        defer { loadingDefaultProvider = nil }
        do {
            if let userError = try await paymentService.setDefaultPayin(provider: provider) {
                setDefaultProviderError = userError
                return
            }
            let store: PaymentStore = globalPresentableStoreContainer.get()
            await store.sendAsync(.fetchPaymentStatus)
        } catch {
            setDefaultProviderError = error.localizedDescription
        }
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return PayinOverviewScreen()
        .environmentObject(NavigationRouter())
        .onAppear {
            let store: PaymentStore = globalPresentableStoreContainer.get()
            store.send(
                .setPaymentStatus(
                    data: .init(
                        status: .active,
                        chargingDay: 27,
                        defaultPayinMethod: nil,
                        payinMethods: [
                            .init(
                                provider: .trustly,
                                status: .active,
                                isDefault: true,
                                details: .bankAccount(account: "*****1234", bank: "Swedbank")
                            ),
                            .init(
                                provider: .swish,
                                status: .active,
                                isDefault: false,
                                details: .swish(phoneNumber: "070-123 45 67")
                            ),
                        ],
                        defaultPayoutMethod: nil,
                        payoutMethods: [],
                        availableMethods: [
                            .init(provider: .invoice, supportsPayin: true, supportsPayout: false)
                        ]
                    )
                )
            )
        }
}
