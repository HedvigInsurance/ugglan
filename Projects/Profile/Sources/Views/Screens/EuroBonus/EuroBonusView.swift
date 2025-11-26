import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct EuroBonusView: View {
    @EnvironmentObject var euroBonusNavigationVm: EuroBonusNavigationViewModel

    public init() {}

    public var body: some View {
        PresentableStoreLens(
            ProfileStore.self,
            getter: { state in
                state.partnerData
            }
        ) { partnerData in
            let fieldValue: String = {
                if let eurobonusNumber = partnerData?.sas?.eurobonusNumber, !eurobonusNumber.isEmpty {
                    return eurobonusNumber
                }
                return L10n.SasIntegration.notConnected
            }()

            hForm {
                hSection {
                    VStack(spacing: 16) {
                        hFloatingField(value: fieldValue, placeholder: L10n.SasIntegration.title) {
                            euroBonusNavigationVm.isChangeEuroBonusPresented = true
                        }
                    }
                }
                .padding(.top, .padding8)
            }
            .sectionContainerStyle(.transparent)
            .hFormAttachToBottom {
                if !(partnerData?.isConnected ?? false) {
                    hSection {
                        InfoCard(
                            text: L10n.SasIntegration.eurobonusInfo,
                            type: .info
                        )
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: L10n.SasIntegration.connectEurobonus),
                            {
                                euroBonusNavigationVm.isChangeEuroBonusPresented = true
                            }
                        )
                        .padding(.vertical, .padding16)
                    }
                } else {
                    hSection {
                        hButton(
                            .large,
                            .ghost,
                            content: .init(title: L10n.SasIntegration.changeEurobonusNumber),
                            {
                                euroBonusNavigationVm.isChangeEuroBonusPresented = true
                            }
                        )
                        .padding(.vertical, .padding16)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        EuroBonusView().navigationBarTitleDisplayMode(.inline)
            .navigationTitle(L10n.SasIntegration.title)
    }
}
