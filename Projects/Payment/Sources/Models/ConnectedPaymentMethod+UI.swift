import hCore
import hCoreUI

extension ConnectedPaymentMethod {
    private var title: String {
        switch method {
        case .trustly:
            L10n.myPaymentBankRowLabel
        case .nordea:
            L10n.bankPayoutMethodCardTitle
        case .swish:
            "Swish"
        case .invoice(let delivery):
            switch delivery {
            case .kivra, nil: "Kivra"
            case .email: L10n.emailRowTitle
            case .unknown: ""
            }
        case .unknown:
            ""
        }
    }

    private var titleForMissedPayment: String {
        switch method {
        case .trustly:
            L10n.bankPayoutMethodCardTitle
        default:
            title
        }
    }

    private var info: String {
        switch method {
        case .trustly, .nordea:
            method.bankAccount?.account ?? ""
        case .swish(let phoneNumber):
            phoneNumber ?? ""
        case .invoice:
            provider.payoutTitle
        case .unknown:
            ""
        }
    }

    private var subtitle: String? {
        switch method {
        case .trustly, .nordea:
            method.bankAccount.map { "\($0.bank) \($0.account)" }
        case .swish(let phoneNumber):
            phoneNumber
        case .invoice, .unknown:
            nil
        }
    }

    var isPending: Bool {
        status == .pending
    }

    /// How the method reads as a row: the provider over the account or number it uses.
    var item: ItemModel {
        .init(title: title, subTitle: isPending ? L10n.referralPendingStatusLabel : subtitle)
    }

    /// How the method reads in the overdue breakdown, where it is one labelled value rather
    /// than a row — Trustly is the member's bank there, not "direct debit".
    var missedPaymentRow: (label: String, value: String) {
        (titleForMissedPayment, info)
    }
}
