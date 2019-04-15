//
//  PaymentNeedsSetupSection.swift
//  UITests
//
//  Created by Axel Backlund on 2019-04-15.
//

import Flow
import Form
import Foundation
import UIKit

struct PaymentNeedsSetupSection {}

extension PaymentNeedsSetupSection: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let wrapper = UIView()
        
        let containerView = UIView()
        containerView.backgroundColor = .offLightGray
        containerView.layer.cornerRadius = 8
        
        let containerStackView = UIStackView()
        containerStackView.axis = .vertical
        containerStackView.spacing = 12
        containerStackView.alignment = .center
        containerStackView.edgeInsets = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        containerView.addSubview(containerStackView)
        
        containerStackView.snp.makeConstraints { make in
            make.height.width.centerX.centerY.equalToSuperview()
        }
        
        let infoContainer = UIView()
        let infoLabel = MultilineLabel(styledText: StyledText(text: "För att din försäkring ska gälla framöver behöver du koppla ditt bankkonto till Hedvig.", style: .bodyOffBlack))
        bag += infoContainer.add(infoLabel) { labelView in
            labelView.textAlignment = .center
            labelView.snp.makeConstraints { make in
                make.height.width.centerY.centerX.equalToSuperview()
            }
        }
        containerStackView.addArrangedSubview(infoContainer)
        
        let buttonContainer = UIView()
        let connectButton = Button(title: "Koppla betalning", type: .outline(borderColor: .purple, textColor: .purple))
        bag += buttonContainer.add(connectButton) { buttonView in
            buttonView.snp.makeConstraints { make in
                make.height.centerY.centerX.equalToSuperview()
            }
        }
        
        containerStackView.addArrangedSubview(buttonContainer)
        
        wrapper.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(16)
            make.height.equalToSuperview()
        }
        
        return (wrapper, bag)
    }
}
