import Apollo
import AppStateContainer
import Claims
import Foundation
import SwiftUI
import hCore
import hCoreUI

struct MainHomeView: View {
    @AppObservedObject private var claimsStore: ClaimsStore

    var body: some View {
        hSection {
            hText(L10n.HomeTab.welcomeTitleWithoutName, style: .displayXSLong)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            ClaimsCard(allActiveClaims: claimsStore.allActiveClaims)
        }
    }
}
