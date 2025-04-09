import Foundation
import SwiftUI
import hCore
import hCoreUI

struct DiscountCodeSectionView: View {
    @EnvironmentObject var foreverNavigationVm: ForeverNavigationViewModel

    var body: some View {
        VStack(spacing: 0) {
            hSection {
                hFloatingField(
                    value: foreverNavigationVm.foreverData?.discountCode ?? "",
                    placeholder: L10n.ReferralsEmpty.Code.headline
                ) {
                    UIPasteboard.general.string = foreverNavigationVm.foreverData?.discountCode
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
                        .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityValue(L10n.voiceOverCopyCode)
            .accessibilityAddTraits(.isButton)
            hSection {
                VStack(spacing: .padding8) {
                    if let code = foreverNavigationVm.foreverData?.discountCode {
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
            }
            .padding(.vertical, .padding16)
        }
        .sectionContainerStyle(.transparent)
    }
}

struct DiscountCodeSectionView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        return DiscountCodeSectionView()
            .onAppear {
                Dependencies.shared.add(module: Module { () -> ForeverClient in ForeverClientDemo() })
            }
            .environmentObject(ForeverNavigationViewModel())
    }
}
