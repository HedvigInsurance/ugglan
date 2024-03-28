import Flow
import Foundation
import SwiftUI
import hCore
import hCoreUI

enum DirectDebitResultType {
    case success
    case failure

    var headingText: String {
        switch self {
        case .success: return L10n.PayInConfirmation.headline
        case .failure: return L10n.PayInError.headline
        }
    }

    var messageText: String {
        switch self {
        case .success: return ""
        case .failure: return L10n.PayInErrorDirectDebit.body
        }
    }

    var mainButtonText: String {
        switch self {
        case .success: return L10n.PayInConfirmation.continueButton
        case .failure: return L10n.PayInError.retryButton
        }
    }
}

struct DirectDebitResult: View {
    let type: DirectDebitResultType
    @PresentableStore var store: PaymentStore
    let retry: () -> Void

    var body: some View {
        switch type {
        case .success:
            SuccessScreen(
                successViewTitle: type.headingText,
                successViewBody: type.messageText,
                buttons: .init(
                    ghostButton: .init(buttonAction: {
                        store.send(.dismissPayment)
                    })
                )
            )
        case .failure:
            GenericErrorView(
                title: type.headingText,
                description: type.messageText,
                useForm: true,
                icon: .triangle,
                buttons: .init(
                    actionButton: .init(
                        buttonTitle: type.mainButtonText,
                        buttonAction: {
                            retry()
                        }
                    )
                )
            )
        }

    }
}

#Preview{
    DirectDebitResult(type: .success, store: .init(), retry: {})
}
