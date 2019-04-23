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
        
        let view = UIView()
        let morePendingInsuranceInfo = MultilineLabel(styledText: StyledText(
            text: "Du är fortfarande försäkrad hos ditt tidigare försäkringsbolag. Vi har påbörjat flytten och den 31 maj 2019 är du är kund hos Hedvig!",
            style: .bodyOffBlack
        ))
        
        bag += view.add(morePendingInsuranceInfo) { infoLabel in
            infoLabel.textAlignment = .center
            infoLabel.snp.makeConstraints { make in
                make.width.centerX.equalToSuperview()
                make.top.equalToSuperview().inset(20)
                make.bottom.equalToSuperview().inset(10)
            }
        }
        
        return (view, bag)
    }
}
