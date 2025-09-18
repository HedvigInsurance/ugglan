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
                    hText(vm.discount.displayValue, style: displayValueStyle)
                        .foregroundColor(getStatusColor)
                }
                HStack(alignment: .top) {
                    if let title = vm.discount.description {
                        hText(title, style: .label)
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
    @hColorBuilder
    private var getStatusColor: some hColor {
        if vm.shouldShowExpire {
            hSignalColor.Red.element
        } else {
            hTextColor.Opaque.secondary
        }
    }

    private var displayValueStyle: HFontTextStyle {
        switch vm.discount.type {
        case .discount:
            return .label
        case .referral:
            return .body1
        case .paymentsDiscount:
            return .body1
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
        switch discount.type {
        case .discount(let status):
            return status == .terminated
        case .referral:
            return false
        case .paymentsDiscount:
            return false
        }
    }
}

struct PaymentDetailsDiscount_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> hCampaignClient in hCampaignClientDemo() })
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        let discount1: Discount = .init(
            code: "231223",
            displayValue: "",
            description: "Very long name that needs to go into 2 rows so we can test it",
            discountId: "1",
            type: .paymentsDiscount
        )
        let discount2: Discount = .init(
            code: "2312231",
            displayValue: "",
            description: "Very long name that needs to go into 2 rows",
            discountId: "1",
            type: .paymentsDiscount
        )
        return VStack {
            DiscountDetailView(vm: .init(options: [.showExpire, .forPayment], discount: discount1))
            DiscountDetailView(vm: .init(options: [.showExpire], discount: discount2))
        }
        .environmentObject(Router())
    }
}
