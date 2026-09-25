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
        case .swish, .nordea, .unknown: nil
        }
    }

    public var infoTextForPendingStatus: String? {
        switch self {
        case .trustly: L10n.paymentsInProgress
        case .invoice: L10n.paymentsInProgressKivra
        case .swish, .nordea, .unknown: nil
        }
    }

    @MainActor
    @ViewBuilder
    public var image: some View {
        switch self {
        case .trustly, .unknown:
            ZStack {
                RoundedRectangle(cornerRadius: .cornerRadiusS)
                    .fill(hBackgroundColor.negative)
                    .frame(width: 40, height: 40)
                hCoreUIAssets.trustly.view
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24)
                    .foregroundColor(hTextColor.Opaque.negative)
            }
        case .invoice: hCoreUIAssets.kivra.view.resizable().frame(width: 40, height: 40)
        case .swish:
            ZStack {
                RoundedRectangle(cornerRadius: .cornerRadiusS)
                    .fill(hBackgroundColor.negative)
                    .frame(width: 40, height: 40)
                hCoreUIAssets.swish.view
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 29)
            }
        case .nordea:
            ZStack {
                RoundedRectangle(cornerRadius: .cornerRadiusS)
                    .fill(hBackgroundColor.negative)
                    .frame(width: 40, height: 40)
                hCoreUIAssets.payments.view
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 26)
            }
        }
    }
}

#Preview {
    VStack {
        ForEach(PaymentProvider.allCases) { provider in
            provider.image
        }
    }
}
