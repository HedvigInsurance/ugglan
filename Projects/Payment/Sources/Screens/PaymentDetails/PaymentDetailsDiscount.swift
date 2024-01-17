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
                    if vm.options.contains(.forPayment), let discount = vm.discount.amount {
                        hText(discount.formattedNegativeAmount)
                    } else {
                        hText(vm.discount.title)
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        if vm.options.contains(.forPayment) {
                            hText(vm.discount.title, style: .standardSmall)
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(vm.discount.listOfAffectedInsurances) { affectedInsurance in
                                    hText(affectedInsurance.displayName, style: .standardSmall)
                                }
                            }
                        }
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
                    if vm.options.contains(.forPayment) {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(vm.discount.listOfAffectedInsurances) { affectedInsurance in
                                hText(affectedInsurance.displayName, style: .standardSmall)
                            }
                        }
                    }
                }
            }
            .foregroundColor(hTextColor.secondary)
        }
        .hWithoutHorizontalPadding
        .dividerInsets(.all, 0)
    }

    @hColorBuilder
    private var getCodeTextColor: some hColor {
        if vm.shouldShowExpire {
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
        static let forPayment = PaymentDetailsDiscountOptions(rawValue: 1 << 2)
    }

    var shouldShowExpire: Bool {
        options.contains(.showExpire) && !discount.isValid
    }

    var shouldShowRemove: Bool {
        options.contains(.enableRemoving) && discount.isValid && discount.canBeDeleted
    }

    func startRemoveCode() {
        if shouldShowRemove {
            store.send(.navigation(to: .openDeleteCampaing(discount: discount)))
        }
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
            listOfAffectedInsurances: [
                .init(id: "id 11", displayName: "DISPLAY NAME"),
                .init(id: "id 12", displayName: "DISPLAY NAME 2"),
            ],
            validUntil: "2023-12-06",
            canBeDeleted: false
        )
        return PaymentDetailsDiscountView(vm: .init(options: [.showExpire, .forPayment], discount: discount))
    }
}
