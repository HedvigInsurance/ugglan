//
//  PendingInsurance.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-22.
//

import Flow
import Form
import Foundation

struct PendingInsurance {}

extension PendingInsurance: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 15
        stackView.edgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        
        let pendingInsuranceHeader = MultilineLabel(styledText: StyledText(text: "Din försäkring är på gång!", style: .bodyOffBlack))
        bag += stackView.addArranged(pendingInsuranceHeader)
        
        let countdown = CountdownShapes()
        let moreInfo = PendingInsuranceMoreInfo()
        
        let expandableView = ExpandableRow(content: countdown, expandedContent: moreInfo, transparent: true)
        
        bag += stackView.addArranged(expandableView)
        
        let openButton = Button(title: "Mer info", type: .standardSmall(backgroundColor: .lightGray, textColor: .offBlack))
        bag += openButton.onTapSignal.map { !expandableView.isOpenSignal.value }.bindTo(expandableView.isOpenSignal)
        bag += expandableView.isOpenSignal.map { $0 ? "Mindre info" : "Mer info" }.bindTo(openButton.title)
        
        bag += stackView.addArranged(openButton)
        
        return (stackView, bag)
    }
}
