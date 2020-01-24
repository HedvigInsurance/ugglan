//
//  LatePaymentHeaderCard.swift
//  test
//
//  Created by Pavel Barros Quintanilla on 2020-01-23.
//

import Foundation
import Flow
import Presentation
import UIKit
import Apollo
import Form

struct LatePaymentHeaderSection {
    @Inject var client: ApolloClient
}

extension LatePaymentHeaderSection: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        view.layer.cornerRadius = 5
        view.backgroundColor = .coral200
        
        let containerView = UIStackView()
        containerView.layoutMargins = UIEdgeInsets(inset: 5)
        containerView.axis = .horizontal
        containerView.alignment = .top
        
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        let dataSignal = self.client.watch(query: MyPaymentQuery()).map { $0.data }
        
        let failedChargesSignalData = dataSignal.map { $0?.balance.failedCharges }
        let nextPaymentSignalData = dataSignal.map { $0?.nextChargeDate }
        
        let icon = Icon(icon: Asset.pinkCircularExclamationPoint, iconWidth: 15)
        containerView.addArrangedSubview(icon)
        
        icon.snp.makeConstraints { make in
            make.width.equalTo(15)
        }
        
        let infoLabel = MultilineLabel(value: "PLACEHOLDER TEXT", style: .body)
        bag += containerView.addArranged(infoLabel)
        
        bag += combineLatest(failedChargesSignalData, nextPaymentSignalData).onValue({ failedCharges, nextPayment in
            guard let nextPayment = nextPayment, let failedCharges = failedCharges else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-,yyyy"
            
            if let date = dateFormatter.date(from: nextPayment) {
                infoLabel.styledTextSignal.value.text = "Du ligger \(failedCharges) månader efter med dina betalningar. Vi kommer att dra mer pengar än din odinarie premie den \(date)."
            }
        })
        
        return (view, bag)
    }
}
