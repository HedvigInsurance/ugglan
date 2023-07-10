import Flow
import Form
import Foundation
import SwiftUI
import hCore
import hCoreUI

struct DiscountCodeSectionView: View {
    @PresentableStore var store: ForeverStore

    var body: some View {
        VStack(spacing: 0) {
            hSection {
                HStack {
                    hText(L10n.ReferralsEmpty.Code.headline)
                    Spacer()
                    Button(action: {
                        store.send(.showChangeCodeDetail)
                    }) {
                        hText(L10n.ReferralsEmpty.Edit.Code.button)
                            .foregroundColor(hLabelColor.link)
                    }
                }
            }
            .withoutBottomPadding.sectionContainerStyle(.transparent)
            PresentableStoreLens(
                ForeverStore.self,
                getter: { state in
                    state.foreverData?.discountCode
                }
            ) { code in
                if let code = code {
                    Button(action: {
                        UIPasteboard.general.string = code
                        store.send(.showPushNotificationsReminder)
                        Toasts.shared.displayToast(
                            toast: .init(
                                symbol: .icon(hCoreUIAssets.toastIcon.image),
                                body: L10n.ReferralsActiveToast.text
                            )
                        )
                    }) {
                        hSection {
                            hText(code, style: .title3).foregroundColor(hLabelColor.primary).padding()
                        }
                        .withoutBottomPadding
                    }
                    .transition(.opacity)
                }
            }
            .presentableStoreLensAnimation(.spring())

            hSection {
                PresentableStoreLens(
                    ForeverStore.self,
                    getter: { state in
                        state.foreverData?.potentialDiscountAmount
                    }
                ) { potentialDiscount in
                    if let potentialDiscount = potentialDiscount {
                        hText(L10n.ReferralsEmpty.Code.footer(potentialDiscount.formattedAmount), style: .footnote)
                            .foregroundColor(hLabelColor.tertiary).multilineTextAlignment(.center)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}
