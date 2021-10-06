import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CrossSellAbout: View {
    let info: CrossSellInfo

    var body: some View {
        hSection(header: hText("About the insurance")) {
            hText("About")
        }
        .sectionContainerStyle(.transparent)
    }
}
