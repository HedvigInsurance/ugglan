import Addons
import SwiftUI
import hCore
import hCoreUI

struct RemoveAddonBottomSheet: View {
    let removeAddonIntent: RemoveAddonIntent
    let action: (() -> Void)?
    @ObservedObject var contractsNavigationVm: ContractsNavigationViewModel
    private let router = Router()

    var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: .padding32) {
                    VStack(alignment: .leading, spacing: 0) {
                        hText(removeAddonIntent.addonDisplayName).foregroundColor(hTextColor.Opaque.primary)
                        hText(
                            action != nil
                                ? L10n.removeAddonDescription
                                : L10n.removeAddonDescriptionRenewal
                        )
                        .foregroundColor(hTextColor.Translucent.secondary)
                    }

                    VStack(spacing: .padding8) {
                        if let action {
                            hButton(.large, .primary, content: .init(title: L10n.removeAddonButtonTitle), action)
                                .hButtonIsLoading(contractsNavigationVm.isRemoveAddonPresented != nil)
                        } else {
                            hButton(.large, .secondary, content: .init(title: L10n.generalCloseButton)) {
                                router.dismiss()
                            }
                        }
                    }
                }
            }
            .padding(.top, .padding16)
            .padding(.bottom, .padding32)
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
        .embededInNavigation(
            options: [.navigationBarHidden],
            tracking: self
        )
    }
}

extension RemoveAddonBottomSheet: TrackingViewNameProtocol {
    var nameForTracking: String {
        String(describing: RemoveAddonBottomSheet.self)
    }
}
