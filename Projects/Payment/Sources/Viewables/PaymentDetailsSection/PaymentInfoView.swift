import Flow
import Form
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct PaymentInfoView: View {
    @ObservedObject private var vm: MyPaymentInfoViewModel

    public init(urlScheme: String) {
        vm = .init(urlScheme: urlScheme, paymentType: hAnalyticsExperiment.paymentType)
    }
    var body: some View {
        hSection {
            nextPayment
            contractsList
            discounts
            addDiscount
            total
        }
        .withHeader {
            nextPaymentHeader
        }
        .withoutHorizontalPadding
    }

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

                        hText(item.amount?.formattedAmount.addPerMonth ?? "")
                            .foregroundColor(hLabelColor.secondary)
                    }
                }
            }
        }
    }

    private var discounts: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentData?.insuranceCost?.discount
            }
        ) { discount in
            if let discount, discount.floatAmount > 0 {
                hRow {
                    hText(L10n.paymentsDiscountsSectionTitle)
                        .padding(.leading, 2)
                    Spacer()
                    hText(discount.negative.formattedAmount.addPerMonth)
                        .foregroundColor(hLabelColor.secondary)
                }
            }
        }
    }

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
                            .frame(maxHeight: .infinity, alignment: .top)
                        Spacer()
                        hText(reedemCampaign.displayValue ?? "")
                            .fixedSize(horizontal: false, vertical: true)

                            .foregroundColor(hLabelColor.secondary)
                    }
                }
            } else {
                hRow {
                    VStack {
                        Toggle(isOn: $vm.addCodeState.animation()) {
                            hText(L10n.paymentsAddCodeLabel)
                                .padding(.leading, 2)
                        }
                        .toggleStyle(ChecboxToggleStyle(.center))
                        if vm.addCodeState {
                            HStack {
                                hFloatingTextField(
                                    masking: .init(type: .none),
                                    value: $vm.discountText,
                                    equals: $vm.myPaymentEditType,
                                    focusValue: .discount,
                                    placeholder: L10n.referralAddcouponInputplaceholder,
                                    error: $vm.discountError,
                                    onReturn: {}
                                )
                                .hFieldSize(.small)
                                .hFieldAttachToRight({
                                    hButton.MediumButtonPrimaryAlt {
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
                                    .hButtonIsLoading(vm.isLoadingDiscount)
                                    .frame(width: 127, height: 56)

                                })
                                .disabled(vm.isLoadingDiscount)
                                .background(
                                    GeometryReader(content: { proxy in
                                        Color.clear
                                            .onAppear {
                                                vm.fieldHeight = proxy.size.height
                                            }
                                    })
                                )
                            }
                            .transition(.opacity)
                        }
                    }
                }
            }
        }
    }

    private var total: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentData
            }
        ) { paymentData in
            hRow {
                VStack {
                    hText(L10n.PaymentDetails.ReceiptCard.total)
                        .padding(.leading, 2)
                    Spacer()
                }
                Spacer()
                VStack(alignment: .trailing) {
                    HStack {
                        if paymentData?.insuranceCost?.gross != paymentData?.insuranceCost?.net {
                            if #available(iOS 15.0, *) {
                                Text(
                                    vm.attributedString(
                                        paymentData?.insuranceCost?.gross?.formattedAmount.addPerMonth ?? ""
                                    )
                                )
                                .foregroundColor(hTextColorNew.secondary)
                                .modifier(hFontModifier(style: .standard))
                            } else {
                                hText(paymentData?.insuranceCost?.gross?.formattedAmount.addPerMonth ?? "")
                                    .foregroundColor(hTextColorNew.secondary)
                            }
                        }
                        hText(paymentData?.insuranceCost?.net?.formattedAmount.addPerMonth ?? "")
                    }
                    hText("", style: .standardSmall)
                        .foregroundColor(hLabelColor.secondary)
                }
            }
        }
    }

    private var nextPaymentHeader: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentData
            }
        ) { paymentData in
            if let amount = paymentData?.chargeEstimation?.gross?.formattedAmountWithoutDecimal {
                hText(amount, style: .standardExtraExtraLarge)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12).fill(hFillColorNew.opaqueOne)
                    )
                    .padding(.horizontal, 16)
            }
        }
    }
}

struct PaymentInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PaymentInfoView(urlScheme: "")
                .onAppear {
                    let store: PaymentStore = globalPresentableStoreContainer.get()
                    let myPaymentQueryData = GiraffeGraphQL.MyPaymentQuery.Data(
                        bankAccount: .init(bankName: "NAME", descriptor: "hyehe"),
                        nextChargeDate: "May 26th 2023",
                        payinMethodStatus: .active,
                        redeemedCampaigns: [
                            .init(code: "CODE", displayValue: "CODE DISPLAY VALUE VALUE CODE DISPLAY VALUE VALUE ")
                        ],
                        balance: .init(currentBalance: .init(amount: "100", currency: "SEK")),
                        chargeHistory: [
                            .init(amount: .init(amount: "2220", currency: "SEK"), date: "2023-10-12"),
                            .init(amount: .init(amount: "222", currency: "SEK"), date: "2023-11-12"),
                            .init(amount: .init(amount: "2120", currency: "SEK"), date: "2023-12-12"),
                        ],
                        insuranceCost: .init(
                            monthlyDiscount: .init(amount: "100", currency: "SEK"),
                            monthlyGross: .init(amount: "100", currency: "SEK"),
                            monthlyNet: .init(amount: "90", currency: "SEK")
                        ),
                        chargeEstimation: .init(
                            charge: .init(amount: "200", currency: "SEKF"),
                            discount: .init(amount: "20", currency: "SEK"),
                            subscription: .init(amount: "180", currency: "SEK")
                        ),
                        activeContractBundles: [
                            .init(id: "1", contracts: [.init(id: "1", typeOfContract: .seHouse, displayName: "NAME")])
                        ]
                    )
                    let paymentData = PaymentData(myPaymentQueryData)
                    store.send(.setPaymentData(data: paymentData))
                }
            Spacer()

        }
    }
}

class MyPaymentInfoViewModel: ObservableObject {
    @Inject var giraffe: hGiraffe
    @PresentableStore var store: PaymentStore
    let urlScheme: String
    @Published var addCodeState = false
    @Published var myPaymentEditType: MyPaymentEditType?
    @Published var discountText = ""
    @Published var isLoadingDiscount: Bool = false
    @Published var discountError: String?
    @Published var fieldHeight: CGFloat = 0
    let paymentType: PaymentType
    public init(urlScheme: String, paymentType: PaymentType) {
        self.urlScheme = urlScheme
        self.paymentType = paymentType
    }

    @available(iOS 15, *)
    func attributedString(_ text: String) -> AttributedString {
        let attributes = AttributeContainer([NSAttributedString.Key.strikethroughStyle: 1])
        let result = AttributedString(text, attributes: attributes)
        return result
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
