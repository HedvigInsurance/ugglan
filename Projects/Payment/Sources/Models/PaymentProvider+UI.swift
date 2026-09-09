import SwiftUI
import hCore
import hCoreUI

extension PaymentProvider {
    public static func from(providerString: String?) -> PaymentProvider {
        guard let provider = providerString?.lowercased() else { return .unknown }
        if provider == "kivra" || provider == "invoice" {
            return .invoice
        } else if provider.hasPrefix("trustly") {
            return .trustly
        } else if provider == "swish" {
            return .swish
        } else if provider == "nordea" {
            return .nordea
        } else {
            return .unknown
        }
    }

    public func infoText(for dueDate: String) -> String? {
        switch self {
        case .trustly: L10n.paymentsPaymentDueInfo(dueDate)
        case .invoice: L10n.kivraPaymentInfo
        default: nil
        }
    }

    public var infoText: String? {
        switch self {
        case .trustly: L10n.paymentsPaymentDetailsInfoDescription
        case .invoice: L10n.kivraPaymentInfo
        default: nil
        }
    }

    public var paymentMethodLabel: String? {
        switch self {
        case .trustly: L10n.paymentsAutogiroLabel
        case .invoice: L10n.paymentsInvoice
        case .swish: "Swish"
        case .nordea, .unknown: nil
        }
    }

    public var infoTextForPendingStatus: String? {
        switch self {
        case .trustly: L10n.paymentsInProgress
        case .invoice: L10n.paymentsInProgressKivra
        case .swish, .nordea, .unknown: nil
        }
    }

    /// The payout copy reads wrong when connecting a method to charge from.
    public var payinTitle: String {
        switch self {
        case .trustly: return "Trustly"
        case .swish: return "Swish"
        case .invoice: return "Kivra"
        case .nordea: return L10n.bankPayoutMethodCardTitle
        case .unknown: return ""
        }
    }

    public var payinSubtitle: String {
        switch self {
        case .trustly: return L10n.paymentOptionTrustlySubtitle
        case .swish: return L10n.paymentOptionSwishSubtitle
        case .invoice: return L10n.paymentOptionInvoiceSubtitle
        case .nordea: return L10n.bankPayoutMethodCardDescription
        case .unknown: return ""
        }
    }

    @MainActor
    @ViewBuilder
    public func image(size: CGFloat = 40) -> some View {
        switch self {
        case .trustly:
            ZStack {
                RoundedRectangle(cornerRadius: .cornerRadiusS)
                    .fill(hBackgroundColor.negative)
                    .frame(width: size, height: size)
                hCoreUIAssets.trustly.view
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.6)
                    .foregroundColor(hTextColor.Opaque.negative)
            }
        case .invoice:
            hCoreUIAssets.kivra.view.resizable().frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusS))
        case .swish:
            ZStack {
                RoundedRectangle(cornerRadius: .cornerRadiusS)
                    .fill(hBackgroundColor.primary)
                    .frame(width: size, height: size)
                hCoreUIAssets.swish.view
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.6)
            }
        case .nordea:
            ZStack {
                RoundedRectangle(cornerRadius: .cornerRadiusS)
                    .fill(hFillColor.Opaque.negative)
                    .frame(width: size, height: size)
                hText(L10n.myPaymentBankRowLabel, style: .finePrint)
                    .foregroundColor(hTextColor.Opaque.secondary)
                    .hWithoutFontMultiplier
            }
        case .unknown:
            RoundedRectangle(cornerRadius: .cornerRadiusS)
                .fill(hBackgroundColor.primary)
                .frame(width: size, height: size)
        }
    }

    @MainActor
    @ViewBuilder
    public func chooseDefaultImage(size: CGFloat = 74) -> some View {
        switch self {
        case .trustly:
            ZStack {
                RoundedRectangle(cornerRadius: .cornerRadiusS)
                    .fill(hBackgroundColor.primary)
                    .frame(width: size, height: size)
                hCoreUIAssets.trustly.view
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.6)
                    .foregroundColor(hTextColor.Opaque.primary)
            }
        default:
            image(size: size)
        }
    }
}

#Preview {
    HStack {
        VStack {
            hText("Regular")
            ForEach(PaymentProvider.allCases) { provider in
                provider.image()
            }
        }
        VStack {
            hText("Choose default image")
            ForEach(PaymentProvider.allCases) { provider in
                provider.chooseDefaultImage()
            }
        }
    }
    .background {
        hSurfaceColor.Opaque.primary
    }
}
