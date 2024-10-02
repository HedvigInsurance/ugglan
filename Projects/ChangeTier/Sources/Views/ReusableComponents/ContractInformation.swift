import SwiftUI
import hCoreUI

struct ContractInformation: View {
    let displayName: String?
    let exposureName: String?

    var body: some View {
        HStack(spacing: .padding12) {
            Image(uiImage: hCoreUIAssets.pillowHome.image)
                .resizable()
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 0) {
                hText(displayName ?? "", style: .heading1)
                hText(exposureName ?? "", style: .body1)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
