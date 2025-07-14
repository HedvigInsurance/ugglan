import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct ProfileRow: View {
    @PresentableStore var store: ProfileStore
    @EnvironmentObject var router: Router
    @EnvironmentObject var profileNavigationViewModel: ProfileNavigationViewModel

    let row: ProfileRowType

    init(
        row: ProfileRowType
    ) {
        self.row = row
    }

    public var body: some View {
        hRow {
            HStack(spacing: .padding16) {
                row.icon
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                hText(row.title)
                Spacer()
            }
        }
        .withChevronAccessory
        .onTap {
            action()
        }
        .environmentObject(router)
    }

    func action() {
        switch row {
        case .myInfo:
            router.push(ProfileRouterType.myInfo)
        case .appInfo:
            router.push(ProfileRouterType.appInfo)
        case .settings:
            router.push(ProfileRouterType.settings)
        case .eurobonus:
            router.push(ProfileRouterType.euroBonus)
        case .travelCertificate:
            router.push(ProfileRedirectType.travelCertificate)
        case .insuranceEvidence:
            profileNavigationViewModel.isCreateInsuranceEvidencePresented = true
        case .certificates:
            router.push(ProfileRouterType.certificates)
        case .claimHistory:
            router.push(ProfileRouterType.claimHistory)
        }
    }
}
