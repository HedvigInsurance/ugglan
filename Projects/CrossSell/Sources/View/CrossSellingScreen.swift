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
        .configureTitleView(title: L10n.crossSellTitle, subTitle: L10n.crossSellSubtitle)
    }
}

struct CrossSellingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> CrossSellClient in CrossSellClientDemo() })
        return CrossSellingScreen()
    }
}
