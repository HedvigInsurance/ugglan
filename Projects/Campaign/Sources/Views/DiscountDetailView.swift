import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct DiscountDetailView: View {
    @ObservedObject var vm: PaymentDetailsDiscountViewModel
    @EnvironmentObject var campaignNavigationVm: CampaignNavigationViewModel
    let isReferral: Bool

    public init(
        isReferral: Bool? = false,
        vm: PaymentDetailsDiscountViewModel
    ) {
        self.isReferral = isReferral ?? false
        self.vm = vm
    }

    public var body: some View {
        hRow {
            VStack(alignment: .leading, spacing: .padding4) {
                HStack(alignment: .top) {
                    HStack(spacing: .padding8) {
                        hText(vm.discount.code.uppercased(), style: .label)
                            .foregroundColor(getCodeTextColor)
                            .padding(.vertical, .padding4)
                    }
                    .padding(.horizontal, .padding8)
                    .background(
                        RoundedRectangle(cornerRadius: .padding8)
                            .fill(hSurfaceColor.Translucent.primary)
                    )
                    Spacer()
                    if let amount = vm.discount.amount {
                        let formattedAmount =
                            vm.options.contains(.forPayment)
                            ? amount.formattedNegativeAmount : amount.formattedNegativeAmountPerMonth
                        hText(formattedAmount)
                            .foregroundColor(hTextColor.Translucent.secondary)
                    } else if isReferral, let amount = vm.discount.amount {
                        hText(amount.formattedNegativeAmountPerMonth)
                    } else if vm.options.contains(.forPayment), let amount = vm.discount.amount {
                        hText(amount.formattedNegativeAmount)
                    }
                }
                HStack(alignment: .top) {
                    if let title = vm.discount.title {
                        hText(title, style: .label)
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
            }
            .foregroundColor(hTextColor.Translucent.secondary)
        }
    }

    @hColorBuilder
    private var getCodeTextColor: some hColor {
        if vm.shouldShowExpire {
            hTextColor.Opaque.secondary
        } else {
            hTextColor.Opaque.primary
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
        static let showExpire = PaymentDetailsDiscountOptions(rawValue: 1 << 0)
        public static let forPayment = PaymentDetailsDiscountOptions(rawValue: 1 << 1)
    }

    var shouldShowExpire: Bool {
        options.contains(.showExpire) && !discount.isValid
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
            discountPerReferral: .sek(10),
            listOfAffectedInsurances: [
                .init(id: "id 11", displayName: "DISPLAY NAME"),
                .init(id: "id 12", displayName: "DISPLAY NAME 2"),
            ],
            validUntil: "2026-03-06",
            canBeDeleted: false,
            discountId: "1"
        )

        let discount2: Discount = .init(
            code: "231223",
            amount: .sek(100),
            title: "Very long name that needs to go into 2 rows",
            discountPerReferral: .sek(10),
            listOfAffectedInsurances: [
                .init(id: "id 11", displayName: "DISPLAY NAME"),
                .init(id: "id 12", displayName: "DISPLAY NAME 2"),
            ],
            validUntil: "2023-12-06",
            canBeDeleted: false,
            discountId: "1"
        )
        return VStack {
            DiscountDetailView(vm: .init(options: [.showExpire, .forPayment], discount: discount1))
            DiscountDetailView(vm: .init(options: [.showExpire], discount: discount2))
        }
        .environmentObject(Router())
    }
}
