import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct SignSection {
    @State var isLoading = false
    @PresentableStore var store: OfferStore

}

extension QuoteBundle.AppConfiguration.ApproveButtonTerminology {
    var displayValue: String {
        switch self {
        case .approveChanges:
            return L10n.offerApproveChanges
        case .confirmPurchase:
            return L10n.offerConfirmPurchase
        default:
            return ""
        }
    }
}

extension SignSection: View {
    var body: some View {
        PresentableStoreLens(
            OfferStore.self,
            getter: { state in
                state.offerData?.signMethodForQuotes
            }
        ) { signMethodForQuotes in
            PresentableStoreLens(
                OfferStore.self,
                getter: { state in
                    state.currentVariant?.bundle.appConfiguration.approveButtonTerminology
                }
            ) { approveButtonTerminology in
                switch signMethodForQuotes {
                case .approveOnly:
                    hButton.LargeButton(type: .primary) {
                        isLoading = true
                        store.send(.startSign)
                    } content: {
                        hText(approveButtonTerminology?.displayValue ?? "")
                    }
                default:
                    hText("Unsupported")
                }
            }
        }
        .hButtonIsLoading(isLoading)
        .onReceive(store.actionSignal.publisher) { action in
            if action == .sign(event: .failed) {
                isLoading = false
            }
        }
    }
}
