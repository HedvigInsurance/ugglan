import SwiftUI
import hCore
import hCoreUI

struct CodeChangedView: View {
    var body: some View {
        hSection {
            VStack(spacing: 20) {
                Spacer()
                Image(uiImage: hCoreUIAssets.checkmark.image)
                    .resizable()
                    .foregroundColor(hSignalColorNew.greenElement)
                    .frame(width: 24, height: 24)
                hText(L10n.ReferralsChange.codeChanged)
                Spacer()
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
struct CodeChangedView_Previews: PreviewProvider {
    static var previews: some View {
        CodeChangedView()
    }
}
