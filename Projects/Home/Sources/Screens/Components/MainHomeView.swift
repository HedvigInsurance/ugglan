import Apollo
import Claims
import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct MainHomeView: View {
    var body: some View {
        hSection {
            hText(L10n.HomeTab.welcomeTitleWithoutName, style: .displayXSLong)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            ClaimsCard()
        }
        .sectionContainerStyle(.transparent)
    }
}
