import Foundation
import SwiftUI
import hCore
import hCoreUI

struct DiscountCodeSectionView: View {
    @EnvironmentObject var foreverNavigationVm: ForeverNavigationViewModel

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
                                foreverNavigationVm.shareCode(code: code)
                            } content: {
                                hText(L10n.ReferralsEmpty.shareCodeButton)
                            }

                            hButton.LargeButton(type: .ghost) {
                                foreverNavigationVm.isChangeCodePresented = true
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
                Dependencies.shared.add(module: Module { () -> ForeverService in ForeverServiceDemo() })
            }
    }
}
