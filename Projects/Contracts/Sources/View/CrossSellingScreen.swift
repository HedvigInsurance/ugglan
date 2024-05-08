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
