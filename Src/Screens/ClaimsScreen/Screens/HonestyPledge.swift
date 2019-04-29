//
//  HonestyPledge.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-24.
//

import Foundation
import Flow
import Presentation
import UIKit

struct HonestyPledge {}

extension HonestyPledge: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let containerStackView = UIStackView()
        containerStackView.alignment = .leading
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.edgeInsets = UIEdgeInsets(horizontalInset: 32, verticalInset: 25)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 10
        
        containerStackView.addArrangedSubview(stackView)
        
        let titleLabel = MultilineLabel(value: "Ditt hederslöfte", style: .standaloneLargeTitle)
        bag += stackView.addArranged(titleLabel)
        
        let descriptionLabel = MultilineLabel(
            value: "Jag förstår att Hedvig bygger på tillit. Jag lover att jag berättat om händelsen precis som den var, och bara ta ut den ersättning jag har rätt till.",
            style: .bodyOffBlack
        )
        bag += stackView.addArranged(descriptionLabel)
        
        let slideToClaim = SlideToClaim()
        bag += stackView.addArranged(slideToClaim.wrappedIn(UIStackView())) { slideToClaimStackView in
            slideToClaimStackView.edgeInsets = UIEdgeInsets(horizontalInset: 0, verticalInset: 20)
            slideToClaimStackView.isLayoutMarginsRelativeArrangement = true
        }
        
        viewController.view = containerStackView
        
        return (viewController, Future { completion in
            bag += slideToClaim.onValue {
                completion(.success)
            }
            
            return DelayedDisposer(bag, delay: 1)
        })
    }
}
