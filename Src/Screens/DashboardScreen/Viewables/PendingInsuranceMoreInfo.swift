//
//  PendingInsuranceMoreInfo.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-22.
//

import Flow
import Form
import Foundation

struct PendingInsuranceMoreInfo {}

extension PendingInsuranceMoreInfo: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let view = UIStackView()
        view.axis = .vertical
        view.edgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        
        view.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(400)
        }
        
        let morePendingInsuranceInfo = MultilineLabel(styledText: StyledText(
            text: "Du är fortfarande försäkrad hos ditt tidigare försäkringsbolag. Vi har påbörjat flytten och den 31 maj 2019 är du är kund hos Hedvig!",
            style: .bodyOffBlack
        ))
        
        bag += view.addArranged(morePendingInsuranceInfo) { infoLabel in
            infoLabel.textAlignment = .center
            
            infoLabel.snp.makeConstraints { make in
                make.height.equalTo(100)
            }
            
            bag += morePendingInsuranceInfo.intrinsicContentSizeSignal.onValue { size in
                infoLabel.snp.makeConstraints { make in
                    make.height.equalTo(size.height)
                }
            }
        }
        
        return (view, bag)
    }
}
