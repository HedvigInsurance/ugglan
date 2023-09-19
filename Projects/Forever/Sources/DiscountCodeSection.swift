import Flow
import Form
import Foundation
import SwiftUI
import hCore
import hCoreUI

struct DiscountCodeSectionView: View {
    @PresentableStore var store: ForeverStore
    var body: some View {
        PresentableStoreLens(
            ForeverStore.self,
            getter: { state in
                state.foreverData?.discountCode
            }
        ) { code in
            if let code = code {
                VStack(spacing: 0) {
                    hSection {
                        hFloatingField(value: code, placeholder: L10n.ReferralsEmpty.Code.headline) {
                            UIPasteboard.general.string = code
                            Toasts.shared.displayToast(
                                toast: .init(
                                    symbol: .icon(hCoreUIAssets.tick.image),
                                    body: L10n.ReferralsActiveToast.text
                                )
                            )
                        }
                        .hFieldTrailingView {
                            Image(uiImage: hCoreUIAssets.copy.image)
                        }
                    }
                    hSection {
                        VStack(spacing: 8) {
                            hButton.LargeButton(type: .primary) {
                                store.send(
                                    .showShareSheetOnly(
                                        code: code,
                                        discount: store.state.foreverData?.potentialDiscountAmount.formattedAmount ?? ""
                                    )
                                )
                            } content: {
                                hText(L10n.ReferralsEmpty.shareCodeButton)
                            }
                            hButton.LargeButton(type: .ghost) {
                                store.send(.showChangeCodeDetail)
                            } content: {
                                hText(L10n.ReferralsChange.changeCode)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .presentableStoreLensAnimation(.spring())
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
