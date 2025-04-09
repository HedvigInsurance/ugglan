import Foundation
import SwiftUI
import hCore
import hCoreUI

struct DiscountCodeSectionView: View {
    @EnvironmentObject var foreverNavigationVm: ForeverNavigationViewModel

    var body: some View {
        VStack(spacing: 0) {
            DiscountCodeField(
                discountCode: foreverNavigationVm.foreverData?.discountCode ?? "",
                onTap: {
                    UIPasteboard.general.string = foreverNavigationVm.foreverData?.discountCode
                    Toasts.shared.displayToastBar(
                        toast: .init(
                            type: .campaign,
                            icon: hCoreUIAssets.checkmark.image,
                            text: L10n.ReferralsActiveToast.text
                        )
                    )
                }
            )
            .accessibilityElement(children: .combine)
            .accessibilityValue(L10n.voiceOverCopyCode)
            .accessibilityAddTraits(.isButton)

            if let code = foreverNavigationVm.foreverData?.discountCode {
                ActionButtons(
                    code: code,
                    onShare: { foreverNavigationVm.shareCode(code: code) },
                    onChange: { foreverNavigationVm.isChangeCodePresented = true }
                )
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

private struct DiscountCodeField: View {
    let discountCode: String
    let onTap: () -> Void

    var body: some View {
        hSection {
            hFloatingField(
                value: discountCode,
                placeholder: L10n.ReferralsEmpty.Code.headline,
                onTap: onTap
            )
            .hFieldTrailingView {
                Image(uiImage: hCoreUIAssets.copy.image)
                    .accessibilityHidden(true)
            }
        }
    }
}

private struct ActionButtons: View {
    let code: String
    let onShare: () -> Void
    let onChange: () -> Void

    var body: some View {
        hSection {
            VStack(spacing: .padding8) {
                hButton.LargeButton(type: .primary, action: onShare) {
                    hText(L10n.ReferralsEmpty.shareCodeButton)
                }
                hButton.LargeButton(type: .ghost, action: onChange) {
                    hText(L10n.ReferralsChange.changeCode)
                }
            }
        }
        .padding(.vertical, .padding16)
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
