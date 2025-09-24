import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct DiscountDetailView: View {
    @EnvironmentObject var campaignNavigationVm: CampaignNavigationViewModel
    let isExpired: Bool
    let options: PaymentDetailsDiscountOptions
    let discount: Discount
    public init(
        discount: Discount,
        options: PaymentDetailsDiscountOptions,
    ) {
        self.discount = discount
        self.options = options
        self.isExpired = {
            switch discount.type {
            case .discount(let status):
                return status == .terminated
            case .referral:
                return false
            case .paymentsDiscount:
                return false
            }
        }()
    }

    public var body: some View {
        hRow {
            VStack(alignment: .leading, spacing: .padding4) {
                HStack(alignment: .top, spacing: 0) {
                    hText(discount.code.uppercased(), style: .label)
                        .foregroundColor(getCodeTextColor)
                        .padding(.vertical, .padding4)
                        .padding(.horizontal, .padding8)
                        .background(
                            RoundedRectangle(cornerRadius: .padding8)
                                .fill(hSurfaceColor.Translucent.primary)
                        )
                        .accessibilityLabel(L10n.voiceoverBundleDiscountTag(discount.code))
                        .layoutPriority(1)
                    Spacer(minLength: .padding8)
                    hText(discount.displayValue, style: displayValueStyle)
                        .foregroundColor(getStatusColor)
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 50)
                }
                HStack(alignment: .top) {
                    if let title = discount.description {
                        hText(title, style: .label)
                    }
                }
            }
            .foregroundColor(hTextColor.Translucent.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    @hColorBuilder
    private var getCodeTextColor: some hColor {
        if isExpired {
            hTextColor.Opaque.secondary
        } else {
            hTextColor.Opaque.primary
        }
    }
    @hColorBuilder
    private var getStatusColor: some hColor {
        if isExpired {
            hSignalColor.Red.element
        } else {
            hTextColor.Opaque.secondary
        }
    }

    private var displayValueStyle: HFontTextStyle {
        switch discount.type {
        case .discount:
            return .label
        case .referral:
            return .body1
        case .paymentsDiscount:
            return .body1
        }
    }
}

public struct PaymentDetailsDiscountOptions: OptionSet, Sendable {
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public let rawValue: UInt
    static let showExpire = PaymentDetailsDiscountOptions(rawValue: 1 << 0)
    public static let forPayment = PaymentDetailsDiscountOptions(rawValue: 1 << 1)
}

struct PaymentDetailsDiscount_Previews: PreviewProvider {
    static var previews: some View {
        let discount1: Discount = .init(
            code: "231223",
            displayValue: "Display value that goes into more lines, it should be fine",
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
            DiscountDetailView(discount: discount1, options: [.showExpire, .forPayment])
            DiscountDetailView(discount: discount2, options: [.showExpire])
        }
    }
}
