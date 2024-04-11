import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingScreen: View {

    public init() {}

    public var body: some View {
        hForm {
            CrossSellingStack(withHeader: false)
        }
        .navigationTitle(L10n.InsuranceTab.CrossSells.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CrossSellingScreen_Previews: PreviewProvider {
    static var previews: some View {
        CrossSellingScreen()
    }
}

//extension CrossSellingScreen {
//    public static func journey<ResultJourney: JourneyPresentation>(
//        @JourneyBuilder resultJourney: @escaping (_ result: ContractsResult) -> ResultJourney
//    ) -> some JourneyPresentation {
//        HostingJourney(
//            ContractStore.self,
//            rootView: CrossSellingScreen(),
//            style: .detented(.scrollViewContentSize),
//            options: [.largeNavigationBar, .blurredBackground]
//        ) { action in
//            if case let .openCrossSellingWebUrl(url) = action {
//                resultJourney(.openCrossSellingWebUrl(url: url))
//            }
//        }
//        .configureTitle(L10n.InsuranceTab.CrossSells.title)
//    }
//}
