import SwiftUI
import hCore
import hCoreUI

public struct ConfirmChangeAddonScreen: View {
    @EnvironmentObject var addonNavigationVm: ChangeAddonNavigationViewModel

    public var body: some View {
        hForm {}
            .hFormContentPosition(.compact)
            .hFormAttachToBottom {
                hSection {
                    VStack(spacing: .padding32) {
                        VStack(alignment: .leading, spacing: 0) {
                            hText(L10n.addonFlowConfirmationTitle)
                            hText(
                                L10n.addonFlowConfirmationDescription(
                                    addonNavigationVm.changeAddonVm!.addonOffer?.activationDate?
                                        .displayDateDDMMMYYYYFormat ?? ""
                                )
                            )
                            .foregroundColor(hTextColor.Translucent.secondary)
                        }
                        VStack(spacing: .padding8) {
                            hButton.LargeButton(type: .primary) {
                                addonNavigationVm.isAddonProcessingPresented = true
                                addonNavigationVm.isConfirmAddonPresented = false
                                Task {
                                    await addonNavigationVm.changeAddonVm!.submitAddons()
                                }
                            } content: {
                                hText(L10n.addonFlowConfirmationButton)
                            }

                            hButton.LargeButton(type: .ghost) {
                                addonNavigationVm.isConfirmAddonPresented = false
                            } content: {
                                hText(L10n.generalCloseButton)
                            }
                        }
                        .padding(.bottom, .padding8)
                    }
                }
                .sectionContainerStyle(.transparent)
            }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return ConfirmChangeAddonScreen()
        .environmentObject(ChangeAddonNavigationViewModel(input: .init()))
}
