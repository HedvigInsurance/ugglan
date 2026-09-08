import hCore
import hCoreUI

extension ConnectedPaymentMethod {
    var title: String {
        switch method {
        case .trustly, .nordea:
            L10n.myPaymentBankRowLabel
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

    var titleForMissedPayment: String {
        switch method {
        case .trustly:
            L10n.bankPayoutMethodCardTitle
        default:
            title
        }
    }

    var info: String {
        switch method {
        case .trustly(let bankAccount), .nordea(let bankAccount):
            bankAccount?.account ?? ""
        case .swish(let phoneNumber):
            phoneNumber ?? ""
        case .invoice:
            provider.payoutTitle
        case .unknown:
            ""
        }
    }

    var subtitle: String? {
        switch method {
        case .trustly(let bankAccount), .nordea(let bankAccount):
            bankAccount.map { "\($0.bank) \($0.account)" }
        case .swish(let phoneNumber):
            phoneNumber
        case .invoice, .unknown:
            nil
        }
    }

    var isPending: Bool {
        status == .pending
    }

    var item: ItemModel {
        .init(title: title, subTitle: isPending ? L10n.referralPendingStatusLabel : subtitle)
    }
}
