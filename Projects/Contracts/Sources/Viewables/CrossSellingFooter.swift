import Apollo
import Flow
import Form
import Foundation
import UIKit
import hCore
import hCoreUI
import hGraphQL
import Presentation
import SwiftUI

class HostingView<Content: View>: UIView {
    let rootViewHostingController: UIHostingController<Content>
    
    public required init(rootView: Content) {
       self.rootViewHostingController = .init(rootView: rootView)
       
       super.init(frame: .zero)
       
       rootViewHostingController.view.backgroundColor = .clear
       
       addSubview(rootViewHostingController.view)
           
        rootViewHostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func systemLayoutSizeFitting(
            _ targetSize: CGSize,
            withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
            verticalFittingPriority: UILayoutPriority
        ) -> CGSize {
            rootViewHostingController.view.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: horizontalFittingPriority,
                verticalFittingPriority: verticalFittingPriority
            )
        }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
            systemLayoutSizeFitting(size)
        }
    
    override open func sizeToFit() {
            if let superview = superview {
                frame.size = rootViewHostingController.sizeThatFits(in: superview.frame.size)
            } else {
                frame.size = rootViewHostingController.sizeThatFits(in: .zero)
            }
        }
}

struct CrossSellingStack: View {
    var body: some View {
        VStack(spacing: 12) {
            hText(L10n.InsuranceTab.CrossSells.title, style: .title3)
                .foregroundColor(hLabelColor.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
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
        }.padding(15)
    }
}

struct CrossSellingFooter {  }

extension CrossSellingFooter: Presentable {
    func materialize() -> (UIView, Disposable) {
        let view = HostingView(rootView: CrossSellingStack())
        return (view, NilDisposer())
    }
}
