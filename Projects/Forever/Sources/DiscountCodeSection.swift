import Foundation
import StoreContainer
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
                            Toasts.shared.displayToastBar(
                                toast: .init(
                                    type: .campaign,
                                    icon: hCoreUIAssets.checkmark.image,
                                    text: L10n.ReferralsActiveToast.text
                                )
                            )
                        }
                        .hFieldTrailingView {
                            Image(uiImage: hCoreUIAssets.copy.image)
                        }
                    }
                    hSection {
                        VStack(spacing: 8) {
                            ModalPresentationSourceWrapper(
                                content: {
                                    hButton.LargeButton(type: .primary) {
                                        foreverNavigationVm.shareCode(code: code)
                                    } content: {
                                        hText(L10n.ReferralsEmpty.shareCodeButton)
                                    }
                                },
                                vm: foreverNavigationVm.modalPresentationSourceWrapperViewModel
                            )

                            hButton.LargeButton(type: .ghost) {
                                foreverNavigationVm.isChangeCodePresented = true
                            } content: {
                                hText(L10n.ReferralsChange.changeCode)
                            }
                        }
                    }
                    .padding(.vertical, .padding16)
                }
            }
        }
        .hPresentableStoreLensAnimation(.spring())
        .sectionContainerStyle(.transparent)
    }
}

struct DiscountCodeSectionView_Previews: PreviewProvider {
    @hPresentableStore static var store: ForeverStore
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return DiscountCodeSectionView()
            .onAppear {
                Dependencies.shared.add(module: Module { () -> ForeverClient in ForeverClientDemo() })
            }
    }
}
