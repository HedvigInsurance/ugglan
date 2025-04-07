import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct PaymentDetailsDiscountView: View {
    @ObservedObject var vm: PaymentDetailsDiscountViewModel
    @EnvironmentObject var campaignNavigationVm: CampaignNavigationViewModel

    public init(vm: PaymentDetailsDiscountViewModel) {
        self.vm = vm
    }

    public var body: some View {
        hRow {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    HStack(spacing: 8) {
                        hText(vm.discount.code, style: .label)
                            .foregroundColor(getCodeTextColor)
                            .padding(.vertical, .padding4)
                        if vm.shouldShowRemove {
                            Image(uiImage: hCoreUIAssets.close.image)
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                    }
                    .padding(.horizontal, .padding8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(hSurfaceColor.Opaque.primary)
                    )
                    .onTapGesture {
                        startRemoveCode()
                    }
                    Spacer()
                    if vm.options.contains(.forPayment), let discount = vm.discount.amount {
                        hText(discount.formattedNegativeAmount)
                    } else if let title = vm.discount.title {
                        hText(title).multilineTextAlignment(.trailing)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        if let title = vm.discount.title, vm.options.contains(.forPayment) {
                            hText(title, style: .label)
                        } else if !vm.discount.listOfAffectedInsurances.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(vm.discount.listOfAffectedInsurances) { affectedInsurance in
                                    hText(affectedInsurance.displayName, style: .label)
                                }
                            }
                        }
                        Spacer()
                        if let validUntil = vm.discount.validUntil {
                            if vm.shouldShowExpire {
                                hText(L10n.paymentsExpiredDate(validUntil.displayDate), style: .label)
                                    .foregroundColor(hSignalColor.Red.element)
                            } else {
                                hText(L10n.paymentsValidUntil(validUntil.displayDate), style: .label)
                            }
                        }
                    }
                    if vm.options.contains(.forPayment) {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(vm.discount.listOfAffectedInsurances) { affectedInsurance in
                                hText(affectedInsurance.displayName, style: .label)
                            }
                        }
                    }
                }
            }
            .foregroundColor(hTextColor.Opaque.secondary)
        }
        .hWithoutHorizontalPadding([.row])
        .dividerInsets(.all, 0)
    }

    @hColorBuilder
    private var getCodeTextColor: some hColor {
        if vm.shouldShowExpire {
            hTextColor.Opaque.secondary
        } else {
            hTextColor.Opaque.primary
        }
    }

    func startRemoveCode() {
        if vm.shouldShowRemove {
            campaignNavigationVm.isDeleteCampaignPresented = vm.discount
        }
    }
}

@MainActor
public class PaymentDetailsDiscountViewModel: ObservableObject {
    let options: PaymentDetailsDiscountOptions
    let discount: Discount
    @PresentableStore private var store: CampaignStore

    public init(options: PaymentDetailsDiscountOptions, discount: Discount) {
        self.options = options
        self.discount = discount
    }

    public struct PaymentDetailsDiscountOptions: OptionSet, Sendable {

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public let rawValue: UInt
        static let enableRemoving = PaymentDetailsDiscountOptions(rawValue: 1 << 0)
        static let showExpire = PaymentDetailsDiscountOptions(rawValue: 1 << 1)
        public static let forPayment = PaymentDetailsDiscountOptions(rawValue: 1 << 2)
    }

    var shouldShowExpire: Bool {
        options.contains(.showExpire) && !discount.isValid
    }

    var shouldShowRemove: Bool {
        options.contains(.enableRemoving) && discount.isValid && discount.canBeDeleted
    }

}

struct PaymentDetailsDiscount_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> hCampaignClient in hCampaignClientDemo() })
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })

        let discount1: Discount = .init(
            code: "231223",
            amount: .sek(100),
            title: "Very long name that needs to go into 2 rows so we can test it",
            listOfAffectedInsurances: [
                .init(id: "id 11", displayName: "DISPLAY NAME"),
                .init(id: "id 12", displayName: "DISPLAY NAME 2"),
            ],
            validUntil: "2023-12-06",
            canBeDeleted: false,
            discountId: "1"
        )

        let discount2: Discount = .init(
            code: "231223",
            amount: .sek(100),
            title: "Very long name that needs to go into 2 rows",
            listOfAffectedInsurances: [
                .init(id: "id 11", displayName: "DISPLAY NAME"),
                .init(id: "id 12", displayName: "DISPLAY NAME 2"),
            ],
            validUntil: "2023-12-06",
            canBeDeleted: false,
            discountId: "1"
        )
        return VStack {
            PaymentDetailsDiscountView(vm: .init(options: [.showExpire, .forPayment], discount: discount1))
            PaymentDetailsDiscountView(vm: .init(options: [.showExpire], discount: discount2))
        }
    }
}
