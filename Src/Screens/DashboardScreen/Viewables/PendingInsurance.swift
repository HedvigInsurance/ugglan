//
//  PendingInsurance.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-22.
//

import Flow
import Form
import Foundation

struct PendingInsurance {
    let dataSignal: ReadWriteSignal<DashboardQuery.Data.Insurance?> = ReadWriteSignal(nil)
}

extension PendingInsurance: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 15
        stackView.edgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        
        bag += dataSignal.atOnce().map { $0 == nil || $0?.status == .inactive || $0?.status == .inactiveWithStartDate }.bindTo(stackView, \.isHidden)
        
        bag += dataSignal.atOnce().compactMap { $0?.status } .onValue { insuranceStatus in
            let moreInfo = PendingInsuranceMoreInfo()
            
            switch insuranceStatus {
            case .inactive, .active:
                let content = CountdownShapes()
                let expandableView: ExpandableRow<CountdownShapes, PendingInsuranceMoreInfo> = ExpandableRow(content: content, expandedContent: moreInfo, transparent: true)
                addBottomContent(view: expandableView)
            case .inactiveWithStartDate:
                let content = Countdown()
                let expandableView: ExpandableRow<Countdown, PendingInsuranceMoreInfo> = ExpandableRow(content: content, expandedContent: moreInfo, transparent: true)
                addBottomContent(view: expandableView)
                // Start date
                ()
            default:
                ()
            }
        }
        
        func addBottomContent<G: Viewable>(view: ExpandableRow<G, PendingInsuranceMoreInfo>) {
            
            stackView.subviews.forEach { view in
                view.removeFromSuperview()
            }
            
            let pendingInsuranceHeader = MultilineLabel(styledText: StyledText(text: "Din försäkring är på gång!", style: .bodyOffBlack))
            bag += stackView.addArranged(pendingInsuranceHeader)
            
            bag += stackView.addArranged(view)
            
            let buttonContainer = UIView()
            let openButton = Button(title: "Mer info", type: .standardSmall(backgroundColor: .lightGray, textColor: .offBlack))
            let closeButton = Button(title: "Mindre info", type: .standardSmall(backgroundColor: .lightGray, textColor: .offBlack))
            
            let isOpenSignal = view.isOpenSignal.atOnce()
            
            bag += buttonContainer.add(openButton) { openButtonView in
                openButtonView.snp.makeConstraints { make in
                    make.height.centerX.centerY.equalToSuperview()
                }
                
                openButtonView.alpha = view.isOpenSignal.value ? 0.0 : 1.0
                
                bag += isOpenSignal.map { $0 ? 0.0 : 1.0 }.animated(style: .easeOut(duration: 0.5, delay: 0), animations: { alpha in
                    openButtonView.alpha = alpha
                })
            }
            
            bag += openButton.onTapSignal.map { true }.bindTo(view.isOpenSignal)
            
            bag += buttonContainer.add(closeButton) { closeButtonView in
                closeButtonView.snp.makeConstraints { make in
                    make.width.height.centerX.centerY.equalToSuperview()
                }
                
                closeButtonView.alpha = view.isOpenSignal.value ? 1.0 : 0.0
                
                bag += isOpenSignal.map { $0 ? 1.0 : 0.0 }.animated(style: .easeOut(duration: 0.2, delay: 0), animations: { alpha in
                    closeButtonView.alpha = alpha
                })
            }
            
            bag += closeButton.onTapSignal.map { false }.bindTo(view.isOpenSignal)
            
            stackView.addArrangedSubview(buttonContainer)
        }
        
        return (stackView, bag)
    }
}
