import Apollo
import Foundation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct TerminatedSectionView<Claims: View>: View {
    var memberName: String
    var claimsContent: Claims

    var body: some View {
        hSection {
            VStack(alignment: .leading, spacing: 16) {
                L10n.HomeTab.terminatedWelcomeTitle(memberName).hText(.title1)
                    .multilineTextAlignment(.center)
            }
            claimsContent
        }
        .sectionContainerStyle(.transparent)
    }
}
