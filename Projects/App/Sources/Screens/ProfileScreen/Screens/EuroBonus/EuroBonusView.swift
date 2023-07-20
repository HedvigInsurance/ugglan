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
                return "Not connected"
            }()

            hForm {
                hSection {
                    VStack(spacing: 16) {
                        hFloatingField(value: fieldValue, placeholder: "EuroBonus") {
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
                            text: "You need to connect your EuroBonus number to your account in oder to earn points",
                            type: .info
                        )
                        hButton.LargeButtonPrimary {
                            store.send(.openChangeEuroBonus)
                        } content: {
                            hText("Connect EuroBonus")
                        }
                        .padding(.vertical, 16)
                    }
                } else {
                    hSection {
                        hButton.LargeButtonGhost {
                            store.send(.openChangeEuroBonus)
                        } content: {
                            hText("Change EuroBonus number")
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
                .navigationTitle("EuroBonus")
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
