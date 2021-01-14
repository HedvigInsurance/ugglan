import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct PlanRow: Hashable {
    let title: String
    let discount: String
    let message: String
}

extension PlanRow: Reusable {
    
    static func makeAndConfigure() -> (make: UIView, configure: (PlanRow) -> Disposable) {
        let titleLabel = UILabel(value: "", style: .brand(.title1(color: .primary)))
        
        let discountLabel = UILabel(value: "", style: .brand(.title1(color: .primary)))
        
        let containerView = UIStackView()
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.insetsLayoutMarginsFromSafeArea = false
        containerView.axis = .vertical
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 10)
        
        containerView.addArrangedSubview(titleLabel)
        
        containerView.addArrangedSubview(discountLabel)
        
        return (containerView, { `self` in
            titleLabel.text = self.title
            discountLabel.text = self.message
            
            return NilDisposer()
        })
    }
}
