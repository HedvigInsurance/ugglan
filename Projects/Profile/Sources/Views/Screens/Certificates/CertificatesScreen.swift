import Apollo
import AppStateContainer
import SwiftUI
import hCoreUI

public struct CertificatesScreen: View {
    @AppObservedObject var store: ProfileStore
    @EnvironmentObject var profileNavigationVm: ProfileNavigationViewModel

    public var body: some View {
        hForm {
            hSection {
                if store.showTravelCertificate {
                    ProfileRow(row: .travelCertificate)
                }
                if store.canCreateInsuranceEvidence {
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
