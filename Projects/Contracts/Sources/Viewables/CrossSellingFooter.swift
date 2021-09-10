import Apollo
import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct CrossSellingStack: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                CrossSellingUnseenCircle()
                hText(L10n.InsuranceTab.CrossSells.title, style: .title3)
                    .foregroundColor(hLabelColor.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            PresentableStoreLens(
                ContractStore.self,
                getter: {
                    $0.contractBundles.flatMap { $0.crossSells }
                }
            ) { crossSells in
                ForEach(crossSells, id: \.title) { crossSell in
                    CrossSellingItem(crossSell: crossSell)
                }
            }
        }
        .padding(15)
    }
}

struct CrossSellingFooter {}

extension CrossSellingFooter: Presentable {
    func materialize() -> (UIView, Disposable) {
        let view = HostingView(rootView: CrossSellingStack())
        return (view, NilDisposer())
    }
}
