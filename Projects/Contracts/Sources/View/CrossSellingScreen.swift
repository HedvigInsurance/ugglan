import SwiftUI
import hCore
import hCoreUI

public struct CrossSellingScreen: View {

    public init() {}

    public var body: some View {
        hForm {
            CrossSellingStack(withHeader: false)
        }
        .hFormContentPosition(.compact)
        .navigationTitle(L10n.InsuranceTab.CrossSells.title)
    }
}

struct CrossSellingScreen_Previews: PreviewProvider {
    static var previews: some View {
        CrossSellingScreen()
    }
}
