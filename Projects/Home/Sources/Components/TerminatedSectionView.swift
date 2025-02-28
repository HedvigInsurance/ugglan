import Apollo
import Claims
import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct TerminatedSectionView: View {
    var body: some View {
        hSection {
            VStack(alignment: .leading, spacing: 16) {
                hText(L10n.HomeTab.welcomeTitleWithoutName, style: .displayXSLong)
                    .multilineTextAlignment(.center)
            }
            ClaimsCard()
        }
        .sectionContainerStyle(.transparent)
    }
}
