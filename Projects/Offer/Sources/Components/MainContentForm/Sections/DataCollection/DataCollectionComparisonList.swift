import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct DataCollectionComparisonList: View {
    var body: some View {
        hSection {
            hRow {
                hCoreUIAssets.wordmark.view
            }
            .withCustomAccessory {
                hText("200 kr/mån")
            }
        }
        hSection {
            hRow {
                hText("Länsförsäkringar")
            }
            .withCustomAccessory {
                hText("200 kr/mån")
            }
        }
    }
}
