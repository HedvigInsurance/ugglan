import Apollo
import Market
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct CertificatesScreen: View {
    @PresentableStore var store: ProfileStore
    @EnvironmentObject var profileNavigationVm: ProfileNavigationViewModel

    public var body: some View {
        hForm {
            PresentableStoreLens(
                ProfileStore.self,
                getter: { state in
                    state
                }
            ) { stateData in
                hSection {
                    if stateData.showTravelCertificate {
                        ProfileRow(row: .travelCertificate)
                    }
                    if stateData.canCreateInsuranceEvidence {
                        ProfileRow(row: .insuranceEvidence)
                    }
                }
                .sectionContainerStyle(.transparent)
                .padding(.top, .padding16)
                .hWithoutHorizontalPadding([.row, .divider])
                .environmentObject(profileNavigationVm)
            }
        }
    }
}
