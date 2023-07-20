import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI

struct EuroBonusView: View {
    @PresentableStore var store: ProfileStore
    var body: some View {
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
                            store.send(.openChangeEuroBonus)
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .hFormAttachToBottom {
                if !(partnerData?.isConnected ?? false) {
                    hSection {
                        InfoCard(
                            text: L10n.SasIntegration.eurobonusInfo,
                            type: .info
                        )
                        hButton.LargeButtonPrimary {
                            store.send(.openChangeEuroBonus)
                        } content: {
                            hText(L10n.SasIntegration.connectEurobonus)
                        }
                        .padding(.vertical, 16)
                    }
                } else {
                    hSection {
                        hButton.LargeButtonGhost {
                            store.send(.openChangeEuroBonus)
                        } content: {
                            hText(L10n.SasIntegration.changeEurobonusNumber)
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
        }

    }
}

struct EuroBonusView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EuroBonusView().navigationBarTitleDisplayMode(.inline)
                .navigationTitle(L10n.SasIntegration.title)
        }
    }
}

extension EuroBonusView {
    static var journey: some JourneyPresentation {
        HostingJourney(
            ProfileStore.self,
            rootView: EuroBonusView()
        ) { action in
            if case .openChangeEuroBonus = action {
                ChangeEuroBonusView.journey
            }
        }
        .configureTitle(L10n.SasIntegration.title)
    }
}
