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
            PresentableStoreLens(
                ForeverStore.self,
                getter: { state in
                    state.foreverData?.discountCode
                }
            ) { code in
                if let code = code {
                    hSection {
                        hFloatingField(value: code, placeholder: L10n.ReferralsEmpty.Code.headline) {
                            UIPasteboard.general.string = code
                            store.send(.showPushNotificationsReminder)
                            Toasts.shared.displayToast(
                                toast: .init(
                                    symbol: .icon(hCoreUIAssets.copy.image),
                                    body: L10n.ReferralsActiveToast.text
                                )
                            )
                        }
                        .hFieldTrailingView {
                            Image(uiImage: hCoreUIAssets.copy.image)
                        }
                    }
                }
            }
            .presentableStoreLensAnimation(.spring())
        }
        .sectionContainerStyle(.transparent)
    }
}

struct DiscountCodeSectionView_Previews: PreviewProvider {
    @PresentableStore static var store: ForeverStore
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return DiscountCodeSectionView()
            .onAppear {
                let foreverData = ForeverData.mock()
                store.send(.setForeverData(data: foreverData))
            }
    }
}
