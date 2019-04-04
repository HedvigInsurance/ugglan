//
//  Peril.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-04.
//

import Flow
import Form
import Foundation
import UIKit

struct Peril {
    let peril: String
    let iconAsset: ImageAsset
    
    init(peril: String) {
        self.peril = peril
        self.iconAsset = Asset.meAssault
    }
}

extension Peril: Reusable {
    static func makeAndConfigure() -> (make: UIStackView, configure: (Peril) -> Disposable) {
        let perilView = UIStackView()
        perilView.axis = .vertical
        
        return (perilView, { peril in
            perilView.arrangedSubviews.forEach({ view in
                view.removeFromSuperview()
            })
            
            let bag = DisposeBag()
            
            let perilIcon = Icon(icon: peril.iconAsset, iconWidth: 30)
            perilView.addArrangedSubview(perilIcon)
            
            let perilTitleLabel = MultilineLabel(styledText: StyledText(text: peril.peril, style: .rowSubtitle))
            bag += perilView.addArranged(perilTitleLabel)
            
            return bag
        })
    }
}
