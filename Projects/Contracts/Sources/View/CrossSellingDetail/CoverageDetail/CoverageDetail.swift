import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct CrossSellingCoverageDetail: View {
    @PresentableStore var store: ContractStore
    var crossSell: CrossSell

    public init(
        crossSell: CrossSell
    ) {
        self.crossSell = crossSell
    }

    public var body: some View {
        hForm {
            hText("Full coverage")
        }
        .hFormAttachToBottom {
            ContinueButton(crossSell: crossSell)
        }
    }
}

extension CrossSellingCoverageDetail {
    public func journey(
        style: PresentationStyle = .default,
        options: PresentationOptions = [.defaults]
    ) -> some JourneyPresentation {
        HostingJourney(
            rootView: self,
            style: style,
            options: options
        )
        .withDismissButton
    }
}
