import Apollo
import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct TerminatedSectionView<Claims: View>: View {
    var claimsContent: Claims

    var body: some View {
        hSection {
            VStack(alignment: .leading, spacing: 16) {
                hText(L10n.HomeTab.welcomeTitleWithoutName, style: .displayXSLong)
                    .multilineTextAlignment(.center)
            }
            claimsContent
        }
        .sectionContainerStyle(.transparent)
    }
}
