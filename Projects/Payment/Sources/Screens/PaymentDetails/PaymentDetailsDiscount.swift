import SwiftUI
import hCore
import hCoreUI

struct PaymentDetailsDiscountView: View {
    @ObservedObject var vm: PaymentDetailsDiscountViewModel

    init(vm: PaymentDetailsDiscountViewModel) {
        self.vm = vm
    }
    var body: some View {
        hRow {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    HStack(spacing: 8) {
                        hText(vm.discount.code, style: .standardSmall)
                            .foregroundColor(getCodeTextColor)
                            .padding(.vertical, 4)
                        if vm.shouldShowRemove {
                            Image(uiImage: hCoreUIAssets.close.image)
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                    }
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(hFillColor.opaqueOne)
                    )
                    .onTapGesture {
                        vm.startRemoveCode()
                    }
                    Spacer()
                    hText(vm.discount.amount.formattedAmount)
                }
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        hText(vm.discount.title, style: .standardSmall)
                        Spacer()
                        if let validUntil = vm.discount.validUntil {
                            if vm.shouldShowExpire {
                                hText(L10n.paymentsExpiredDate(validUntil.displayDate), style: .standardSmall)
                                    .foregroundColor(hSignalColor.redElement)
                            } else {
                                hText(L10n.paymentsValidUntil(validUntil.displayDate), style: .standardSmall)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(vm.discount.listOfAffectedInsurances) { affectedInsurance in
                            hText(affectedInsurance.displayName, style: .standardSmall)
                        }
                    }
                }
            }
            .foregroundColor(hTextColor.secondary)
        }
        .noHorizontalPadding()
        .dividerInsets(.all, 0)
    }

    @hColorBuilder
    private var getCodeTextColor: some hColor {
        if !vm.discount.isValid && vm.options.contains(.showExpire) {
            hTextColor.secondary
        } else {
            hTextColor.primary
        }
    }
}

class PaymentDetailsDiscountViewModel: ObservableObject {
    let options: PaymentDetailsDiscountOptions
    let discount: Discount
    @PresentableStore private var store: PaymentStore
    @Inject private var campaignsService: hCampaignsService

    init(options: PaymentDetailsDiscountOptions, discount: Discount) {
        self.options = options
        self.discount = discount
    }

    struct PaymentDetailsDiscountOptions: OptionSet {
        let rawValue: UInt
        static let enableRemoving = PaymentDetailsDiscountOptions(rawValue: 1 << 0)
        static let showExpire = PaymentDetailsDiscountOptions(rawValue: 1 << 1)
    }

    var shouldShowExpire: Bool {
        options.contains(.showExpire) && !discount.isValid
    }

    var shouldShowRemove: Bool {
        options.contains(.enableRemoving) && discount.isValid
    }

    func startRemoveCode() {
        store.send(.navigation(to: .openDeleteCampaing(code: discount.code)))
    }

}

struct PaymentDetailsDiscount_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> hCampaignsService in hCampaignsServiceDemo() })
        let discount: Discount = .init(
            id: "1",
            code: "231223",
            amount: .sek(100),
            title: "23",
            listOfAffectedInsurances: [],
            validUntil: "2023-11-06"
        )
        return PaymentDetailsDiscountView(vm: .init(options: [.showExpire], discount: discount))
    }
}
