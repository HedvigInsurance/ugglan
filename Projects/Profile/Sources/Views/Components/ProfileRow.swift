import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ProfileRow: View {
    @PresentableStore var store: ProfileStore
    @EnvironmentObject var router: Router

    let row: ProfileRowType

    init(
        row: ProfileRowType
    ) {
        self.row = row
    }

    public var body: some View {
        hRow {
            HStack(spacing: 16) {
                Image(uiImage: row.icon)
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
            router.push(ProfileRedirectType.myInfo)
        case .appInfo:
            router.push(ProfileRedirectType.appInfo)
        case .settings:
            router.push(ProfileRedirectType.settings)
        case .eurobonus:
            router.push(ProfileRedirectType.euroBonus)
        case .travelCertificate:
            router.push(ProfileRedirectType.travelCertificate)
        }
    }
}
