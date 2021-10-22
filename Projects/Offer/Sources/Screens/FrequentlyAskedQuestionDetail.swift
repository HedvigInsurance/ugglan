import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL
import SwiftUI

struct FrequentlyAskedQuestionDetail: View {
    let frequentlyAskedQuestion: QuoteBundle.FrequentlyAskedQuestion
    
    public var body: some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: 18) {
                    hText(
                        frequentlyAskedQuestion.headline ?? "",
                        style: .title1
                    )
                    hText(
                        frequentlyAskedQuestion.headline ?? "",
                        style: .body
                    )
                    .foregroundColor(hLabelColor.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

extension FrequentlyAskedQuestionDetail {
    var journey: some JourneyPresentation {
        HostingJourney(rootView: self, style: .detented(.scrollViewContentSize)).withDismissButton
    }
}
