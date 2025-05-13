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
                    onShare: { vm in
                        foreverNavigationVm.shareCode(code: code, modalPresentationWrapperVM: vm)
                    },
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
    let onShare: (_ vm: ModalPresentationSourceWrapperViewModel) -> Void
    let onChange: () -> Void
    @State var modalPresentationSourceWrapperViewModel = ModalPresentationSourceWrapperViewModel()
    var body: some View {
        hSection {
            VStack(spacing: .padding8) {
                ModalPresentationSourceWrapper(
                    content: {
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: L10n.ReferralsEmpty.shareCodeButton),
                            {
                                onShare(modalPresentationSourceWrapperViewModel)
                            }
                        )
                    },
                    vm: modalPresentationSourceWrapperViewModel
                )

                hButton(
                    .large,
                    .ghost,
                    content: .init(title: L10n.ReferralsChange.changeCode),
                    {
                        onChange()
                    }
                )
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
