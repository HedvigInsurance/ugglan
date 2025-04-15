import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct CertificatesScreen: View {
    @PresentableStore var store: ProfileStore
    var certificates: [ProfileRowType] = []

    public init() {
        if store.state.showTravelCertificate {
            certificates.append(.travelCertificate)
        }
        if store.state.showInsuranceEvidence {
            certificates.append(.insuranceEvidence)
        }
    }

    public var body: some View {
        hForm {
            hSection(certificates, id: \.title) { certificate in
                ProfileRow(row: certificate)
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
            .hWithoutHorizontalPadding([.row, .divider])
        }
        .onAppear {
            store.send(.fetchProfileState)
        }
        .hSetScrollBounce(to: true)
        .onPullToRefresh {
            await store.sendAsync(.fetchProfileState)
        }
        .configureTitle(L10n.profileTitle)
    }
}
