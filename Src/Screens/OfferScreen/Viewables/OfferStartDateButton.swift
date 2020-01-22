//
//  OfferStartDateButton.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-14.
//

import Foundation
import Flow
import UIKit
import Apollo

struct OfferStartDateButton {
    let containerScrollView: UIScrollView
    let presentingViewController: UIViewController
    @Inject var client: ApolloClient
    
    init(containerScrollView: UIScrollView,
         presentingViewController: UIViewController
    ) {
        self.containerScrollView = containerScrollView
        self.presentingViewController = presentingViewController
    }
}





extension OfferStartDateButton: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        
        let containerStackView = UIStackView()
        containerStackView.alignment = .center
        containerStackView.axis = .vertical
        
        let button = UIControl()
        button.layer.borderWidth = 1
        bag += button.applyBorderColor { traitCollection -> UIColor in
            return .white
        }
        
        bag += button.applyCornerRadius { _ -> CGFloat in
            return button.layer.frame.height / 2
        }
        
        containerStackView.addArrangedSubview(button)
        
        bag += containerScrollView.contentOffsetSignal.onValue { contentOffset in
            containerStackView.transform = CGAffineTransform(
                translationX: 0,
                y: (contentOffset.y / 5)
            )
        }
        
        let touchUpInside = button.signal(for: .touchUpInside)
        bag += touchUpInside.feedback(type: .impactLight)
        
        let present = ChooseStartDate()
        
        bag += touchUpInside.onValue({ _ in
            bag += self.presentingViewController.present(
                DraggableOverlay(presentable: present,
                                 presentationOptions: [.defaults , .prefersNavigationBarHidden(true)]
                )
            ).disposable
        })
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.isUserInteractionEnabled = false
        button.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        let keyLabel = UILabel(value: String(key: .START_DATE_BTN), style: .body)
        stackView.addArrangedSubview(keyLabel)
        keyLabel.textColor = .white
        
        let valueLabel = UILabel(value: "", style: .bodyBold)
            valueLabel.textColor = .white
            stackView.addArrangedSubview(valueLabel)
        
            let iconView = Icon(icon: Asset.chevronRightWhite, iconWidth: 20)
            iconView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
            stackView.addArrangedSubview(iconView)
        
        bag += self.client.watch(query: OfferQuery()).onValue { result in
            let calendar = Calendar.current
            guard let startDate = result.data?.lastQuoteOfMember.asCompleteQuote?.startDate?.description.localDateToDate else {
                valueLabel.text = String(key: .CHOOSE_DATE_BTN)
                return
            }

            if calendar.isDateInToday(startDate) {
                valueLabel.text = String(key: .START_DATE_TODAY)
            } else {
                valueLabel.text = startDate.localDateString
            }
        }
        

        
        return (containerStackView, bag)
    }
}
