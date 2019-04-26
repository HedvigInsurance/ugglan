//
//  PendingInsuranceMoreInfo.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-22.
//

import Flow
import Form
import Foundation

struct PendingInsuranceMoreInfo {
    let date: Date?
    
    init(date: Date? = nil) {
        self.date = date
    }
}

extension PendingInsuranceMoreInfo: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let view = UIStackView()
        view.axis = .vertical
        view.edgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        
        view.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(400)
        }
        
        //var text = ""
        
        var text: String {
            if let date = date {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: Localization.Locale.currentLocale.rawValue)
                dateFormatter.dateStyle = .long
                let dateString = dateFormatter.string(from: date)
                
                return String(key: .DASHBOARD_PENDING_HAS_DATE(date: dateString))
            } else {
                return String(key: .DASHBOARD_PENDING_NO_DATE)
            }
        }
        
        let morePendingInsuranceInfo = MultilineLabel(styledText: StyledText(
            text: text,
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
