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
                hRow {
                    VStack {
                        Toggle(isOn: $vm.addCodeState) {
                            hText(L10n.paymentsAddCodeLabel)
                        }
                        if vm.addCodeState {
                            HStack {
                                hFloatingTextField(
                                    masking: .init(type: .none),
                                    value: $vm.discountText,
                                    equals: $vm.myPaymentEditType,
                                    focusValue: .discount,
                                    placeholder: "Skriv in din kod"
                                )
                                hButton.MediumButtonFilled {

                                } content: {
                                    hText(L10n.paymentsAddCodeButtonLabel)
                                        .frame(height: 72)

                                }
                                .hButtonConfigurationType(.primaryAlt)

                            }
                        }
                        if let code = paymentData?.code {
                            HStack(alignment: .center) {
                                hText(code, style: .standardSmall)
                                Spacer()
                            }
                        }
                    }
                }
                .onTapGesture {
                    vm.addCodeState.toggle()
                }
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
                        Image(uiImage: item.type.bgImage)
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
    @State var addCodeState = true
    @State var myPaymentEditType: MyPaymentEditType?
    @State var discountText = ""
    public init(urlScheme: String) {
        self.urlScheme = urlScheme
        let store: PaymentStore = globalPresentableStoreContainer.get()
        addCodeState = store.state.paymentData?.code != nil
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
}

struct MyPaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        MyPaymentsView(urlScheme: Bundle.main.urlScheme ?? "")
            .onAppear {
                let store: PaymentStore = globalPresentableStoreContainer.get()
                let myPaymentQueryData = GiraffeGraphQL.MyPaymentQuery.Data(
                    chargeEstimation: .init(
                        subscription: .init(amount: "20", currency: "SEK"),
                        charge: .init(amount: "30", currency: "SEK"),
                        discount: .init(amount: "10", currency: "SEK")
                    ),
                    bankAccount: .init(bankName: "NAME", descriptor: "hyehe"),
                    nextChargeDate: "May 26th 2023",
                    payinMethodStatus: .active,
                    redeemedCampaigns: [.init(code: "CODE")],
                    balance: .init(currentBalance: .init(amount: "100", currency: "SEK")),
                    chargeHistory: [.init(amount: .init(amount: "2220", currency: "SEKF"), date: "DATE 1")]
                )
                let data = PaymentData(myPaymentQueryData)
                store.send(.setPaymentData(data: data))
            }
    }
}
