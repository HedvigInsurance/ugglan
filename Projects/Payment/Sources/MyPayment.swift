import Adyen
import AdyenDropIn
import Apollo
import Flow
import Form
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

//public struct MyPayment {
//    @Inject var giraffe: hGiraffe
//    @PresentableStore var store: PaymentStore
//    let urlScheme: String
//
//    public init(urlScheme: String) { self.urlScheme = urlScheme }
//}
//
//extension MyPayment: Presentable {
//    public func materialize() -> (UIViewController, Disposable) {
//        let bag = DisposeBag()
//
//        store.send(.load)
//
//        let dataSignal = giraffe.client.watch(
//            query: GiraffeGraphQL.MyPaymentQuery(
//                locale: Localization.Locale.currentLocale.asGraphQLLocale()
//            )
//        )
//        let failedChargesSignalData = dataSignal.map { $0.balance.failedCharges }
//        let nextPaymentSignalData = dataSignal.map { $0.nextChargeDate }
//
//        let viewController = UIViewController()
//        viewController.title = L10n.myPaymentTitle
//
//        let form = FormView()
//        bag += viewController.install(form) { scrollView in
//            bag += scrollView.performEntryAnimation(
//                contentView: form,
//                onLoad: giraffe.client.fetch(
//                    query: GiraffeGraphQL.MyPaymentQuery(
//                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
//                    )
//                ),
//                onError: { _ in }
//            )
//        }
//        bag += dataSignal.animated(style: SpringAnimationStyle.lightBounce()) { _ in form.alpha = 1
//            form.transform = CGAffineTransform.identity
//        }
//
//        bag += combineLatest(failedChargesSignalData, nextPaymentSignalData)
//            .onValueDisposePrevious { failedCharges, nextPayment in let innerbag = DisposeBag()
//                if let failedCharges = failedCharges, let nextPayment = nextPayment {
//                    if failedCharges > 0 {
//                        let latePaymentHeaderCard = LatePaymentHeaderSection(
//                            failedCharges: failedCharges,
//                            lastDate: nextPayment
//                        )
//                        innerbag += form.prepend(latePaymentHeaderCard)
//                        innerbag += form.prepend(Spacing(height: 20))
//                    }
//                }
//                return innerbag
//            }
//
//        let paymentHeaderCard = PaymentHeaderCard()
//        bag += form.prepend(paymentHeaderCard)
//
//        let pastPaymentsSection = PastPaymentsSection(presentingViewController: viewController)
//        bag += form.append(pastPaymentsSection)
//
//        let paymentDetailsSection = PaymentDetailsSection(presentingViewController: viewController)
//        bag += form.append(paymentDetailsSection)
//
//        switch hAnalyticsExperiment.paymentType {
//        case .trustly:
//            let bankDetailsSection = BankDetailsSection(urlScheme: urlScheme)
//            bag += form.append(bankDetailsSection)
//        case .adyen:
//            let cardDetailsSection = CardDetailsSection(urlScheme: urlScheme)
//            bag += form.append(cardDetailsSection)
//
//            let payoutDetailsSection = PayoutDetailsSection(urlScheme: urlScheme)
//            bag += form.append(payoutDetailsSection)
//        }
//
//        bag += form.append(Spacing(height: 20))
//
//        viewController.trackOnAppear(hAnalyticsEvent.screenView(screen: .payments))
//
//        return (viewController, bag)
//    }
//}

public struct MyPaymentsView: View {
    @ObservedObject private var vm: MyPaymentsViewModel

    public init(urlScheme: String) {
        vm = .init(urlScheme: urlScheme)

    }
    public var body: some View {
        LoadingViewWithContent(PaymentStore.self, [.getPaymentData]) {
            hForm {
                payment.padding(.top, 16)
                paymentDetails
            }
            .sectionContainerStyle(.transparent)
            .hFormAttachToBottom {
                PresentableStoreLens(
                    PaymentStore.self,
                    getter: { state in
                        state.paymentData
                    }
                ) { paymentData in
                    hSection {
                        hButton.LargeButtonPrimary {
                            vm.store.send(.openConnectBankAccount)
                        } content: {
                            hText(
                                paymentData?.status == .needsSetup
                                    ? L10n.myPaymentDirectDebitButton : L10n.myPaymentDirectDebitReplaceButton
                            )
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .presentableStoreLensAnimation(.default)
        .useDarkColor
    }

    @ViewBuilder
    private var payment: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentData
            }
        ) { paymentData in
            hSection {
                nextPayment
                contractsList
                discounts
                addDiscount

                hRow {
                    VStack {
                        hText(L10n.PaymentDetails.ReceiptCard.total)
                        Spacer()
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack {
                            if paymentData?.gross != paymentData?.net {
                                if #available(iOS 15.0, *) {
                                    Text(vm.attributedString(paymentData?.gross?.formattedAmount ?? ""))
                                        .foregroundColor(hTextColorNew.secondary)
                                        .modifier(hFontModifier(style: .standard))
                                } else {
                                    hText(paymentData?.gross?.formattedAmount ?? "")
                                        .foregroundColor(hTextColorNew.secondary)
                                }
                            }
                            hText(paymentData?.net?.formattedAmount ?? "")
                        }
                        hText("", style: .standardSmall)
                            .foregroundColor(hLabelColor.secondary)
                    }
                }
                .hWithoutDivider

            }
            .withHeader {
                if let amount = paymentData?.net?.formattedAmount {
                    hText(amount, style: .standardExtraExtraLarge)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12).fill(hFillColorNew.opaqueOne)
                        )
                        .padding(.horizontal, 16)
                }
            }
            .withoutHorizontalPadding
        }
    }

    @ViewBuilder
    private var nextPayment: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentData?.nextPayment?.date
            }
        ) { date in
            hRow {
                if let date {
                    hText(L10n.paymentsNextPaymentSectionTitle)
                    Spacer()
                    hText(date).foregroundColor(hLabelColor.secondary)
                } else {
                    hText(L10n.paymentsCardNoStartdate)
                }
            }
        }
    }
    @ViewBuilder
    private var contractsList: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentData?.contracts
            }
        ) { contracts in
            if let contracts = contracts {
                ForEach(contracts, id: \.id) { item in
                    hRow {
                        Image(uiImage: item.type.pillowType.bgImage)
                            .resizable()
                            .frame(width: 32, height: 32)
                        hText(item.name)
                        Spacer()
                        hText(item.amount?.formattedAmount ?? "").foregroundColor(hLabelColor.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var discounts: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentData?.discount
            }
        ) { discount in
            if let discount {
                hRow {
                    hText(L10n.paymentsDiscountsSectionTitle)
                    Spacer()
                    hText(discount.formattedAmount).foregroundColor(hLabelColor.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var addDiscount: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentData?.reedemCampaigns ?? []
            }
        ) { reedemCampaigns in
            if reedemCampaigns.count > 0 {
                ForEach(reedemCampaigns, id: \.code) { reedemCampaign in
                    hRow {
                        hText(reedemCampaign.code ?? "")
                        Spacer()
                        hText(reedemCampaign.displayValue ?? "")
                            .foregroundColor(hLabelColor.secondary)
                    }
                }
            } else {
                hRow {
                    VStack {
                        Toggle(isOn: $vm.addCodeState.animation()) {
                            hText(L10n.paymentsAddCodeLabel)
                        }
                        if vm.addCodeState {
                            HStack {
                                hFloatingTextField(
                                    masking: .init(type: .none),
                                    value: $vm.discountText,
                                    equals: $vm.myPaymentEditType,
                                    focusValue: .discount,
                                    placeholder: "Skriv in din kod",
                                    error: $vm.discountError,
                                    onReturn: {}
                                )
                                .hFieldSize(.small)
                                .disabled(vm.isLoadingDiscount)
                                .background(
                                    GeometryReader(content: { proxy in
                                        Color.clear
                                            .onAppear {
                                                vm.fieldHeight = proxy.size.height
                                            }
                                            .onChange(of: vm.discountError) { _ in
                                                vm.fieldHeight = proxy.size.height
                                            }
                                    })
                                )
                                hButton.MediumButtonFilled {
                                    Task {
                                        withAnimation {
                                            vm.isLoadingDiscount = true
                                        }
                                        do {
                                            try await vm.submitDiscount()
                                        } catch let error {
                                            withAnimation {
                                                vm.discountError = error.localizedDescription
                                            }
                                        }
                                        withAnimation {
                                            vm.isLoadingDiscount = false
                                        }
                                    }
                                } content: {
                                    hText(L10n.paymentsAddCodeButtonLabel)
                                        .frame(height: vm.fieldHeight)

                                }
                                .hButtonConfigurationType(.primaryAlt)
                                .hButtonIsLoading(vm.isLoadingDiscount)

                            }
                            .transition(.opacity)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var paymentDetails: some View {
        hSection {
            paymentRow
            historyRow
        }
        .withoutHorizontalPadding
    }

    @ViewBuilder
    private var paymentRow: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentData
            }
        ) { paymentData in
            if let status = paymentData?.status,
                status != .needsSetup,
                let bankAccount = paymentData?.bankAccount
            {
                hRow {
                    hText(L10n.PaymentDetails.NavigationBar.title)
                }
                hRow {
                    Image(uiImage: HCoreUIAsset.payments.image)
                        .resizable()
                        .frame(width: 24, height: 24)
                    hText(bankAccount.name ?? "")
                    Spacer()
                    hText(bankAccount.descriptor ?? "").foregroundColor(hLabelColor.secondary)
                }
                if status == .pending {
                    hRow {
                        InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
                    }
                }
            }
        }
    }

    private var historyRow: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentData?.paymentHistory
            }
        ) { history in
            if let history, !history.isEmpty {
                hRow {
                    Image(uiImage: HCoreUIAsset.circularClock.image)
                        .resizable()
                        .frame(width: 24, height: 24)
                    hText(L10n.paymentsPaymentHistoryButtonLabel)
                }
                .withChevronAccessory
                .onTap {
                    vm.openHistory()
                }
            }
        }
    }
}

class MyPaymentsViewModel: ObservableObject {
    @Inject var giraffe: hGiraffe
    @PresentableStore var store: PaymentStore
    let urlScheme: String
    @Published var addCodeState = false
    @Published var myPaymentEditType: MyPaymentEditType?
    @Published var discountText = ""
    @Published var isLoadingDiscount: Bool = false
    @Published var discountError: String?
    @Published var fieldHeight: CGFloat = 0
    public init(urlScheme: String) {
        self.urlScheme = urlScheme
        let store: PaymentStore = globalPresentableStoreContainer.get()
        store.send(.load)

    }

    @available(iOS 15, *)
    func attributedString(_ text: String) -> AttributedString {
        let attributes = AttributeContainer([NSAttributedString.Key.strikethroughStyle: 1])
        let result = AttributedString(text, attributes: attributes)
        return result
    }

    func openHistory() {
        store.send(.openHistory)
    }

    func submitDiscount() async throws {
        try await withCheckedThrowingContinuation { (inCont: CheckedContinuation<Void, Error>) -> Void in
            self.giraffe.client
                .perform(
                    mutation: GiraffeGraphQL.RedeemCodeMutation(
                        code: discountText,
                        locale: Localization.Locale.currentLocale.asGraphQLLocale()
                    )
                )
                .onValue { [weak self] data in
                    guard data.redeemCodeV2.asSuccessfulRedeemResult != nil else {
                        inCont.resume(throwing: AddDiscountError.missing)
                        return
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.store.send(.load)
                    }
                    DispatchQueue.main.async {
                        Toasts.shared.displayToast(
                            toast: Toast(
                                symbol: .icon(hCoreUIAssets.campaignSmall.image),
                                body: L10n.discountRedeemSuccess,
                                subtitle: L10n.discountRedeemSuccessBody
                            )
                        )
                    }
                    inCont.resume()

                }
                .onError { error in
                    inCont.resume(throwing: AddDiscountError.error(message: L10n.General.errorBody))
                }
        }
    }

    enum MyPaymentEditType: hTextFieldFocusStateCompliant {
        static var last: MyPaymentEditType {
            return MyPaymentEditType.discount
        }

        var next: MyPaymentEditType? {
            switch self {
            case .discount:
                return nil
            }
        }

        case discount
    }

    enum AddDiscountError: Error, LocalizedError {
        case error(message: String)
        case missing

        public var errorDescription: String? {
            switch self {
            case let .error(message):
                return message
            case .missing:
                return L10n.discountCodeMissingBody
            }
        }
        var localizedDescription: String {
            switch self {
            case let .error(message):
                return message
            case .missing:
                return L10n.discountCodeMissingBody
            }
        }
    }
}

struct MyPaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        MyPaymentsView(urlScheme: Bundle.main.urlScheme ?? "")
            .onAppear {
                let store: PaymentStore = globalPresentableStoreContainer.get()
                let myPaymentQueryData = GiraffeGraphQL.MyPaymentQuery.Data(
                    bankAccount: .init(bankName: "NAME", descriptor: "hyehe"),
                    nextChargeDate: "May 26th 2023",
                    payinMethodStatus: .pending,
                    redeemedCampaigns: [.init(code: "CODE")],
                    balance: .init(currentBalance: .init(amount: "20", currency: "SEK")),
                    chargeHistory: [.init(amount: .init(amount: "2220", currency: "SEKF"), date: "DATE 1")],
                    activeContractBundles: [
                        .init(id: "1", contracts: [.init(id: "1", typeOfContract: .seHouse, displayName: "name")])
                    ]
                )
                let data = PaymentData(myPaymentQueryData)
                store.send(.setPaymentData(data: data))
            }
    }
}
