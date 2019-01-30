//
//  DirectDebitResult.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-25.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Foundation
import Flow
import Form

enum DirectDebitResultType {
    case success, failure
    
    var icon: ImageAsset {
        switch self {
        case .success:
            return Asset.greenCircularCheckmark
        case .failure:
            return Asset.pinkCircularExclamationPoint
        }
    }
    
    var headingText: String {
        switch self {
        case .success:
            return String(.DIRECT_DEBIT_SUCCESS_HEADING)
        case .failure:
            return String(.DIRECT_DEBIT_FAIL_HEADING)
        }
    }
    
    var messageText: String {
        switch self {
        case .success:
            return String(.DIRECT_DEBIT_SUCCESS_MESSAGE)
        case .failure:
            return String(.DIRECT_DEBIT_FAIL_MESSAGE)
        }
    }
    
    var buttonText: String {
        switch self {
        case .success:
            return String(.DIRECT_DEBIT_SUCCESS_BUTTON)
        case .failure:
            return String(.DIRECT_DEBIT_FAIL_BUTTON)
        }
    }
    
    var buttonType: ButtonType {
        switch self {
        case .success:
            return .standard(backgroundColor: .green, textColor: .white)
        case .failure:
            return .standard(backgroundColor: .pink, textColor: .white)
        }
    }
}

struct DirectDebitResult {
    let type: DirectDebitResultType
}

extension DirectDebitResult: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Future<Void>) {
        let containerView = UIView()
        containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        containerView.alpha = 0
        
        let stackView = CenterAllStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        
        containerView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.edges.equalToSuperview()
        }
        
        let bag = DisposeBag()
        
        let icon = Icon(frame: .zero, icon: type.icon, iconWidth: 40)
        stackView.addArrangedSubview(icon)
        
        let heading = MultilineLabel(
            styledText: StyledText(
                text: type.headingText,
                style: .centeredHeadingOne
            )
        )
        
        bag += stackView.addArangedSubview(heading) { view in
            view.snp.makeConstraints { make in
                make.width.equalTo(containerView.snp.width).inset(20)
            }
        }
        
        let body = MultilineLabel(
            styledText: StyledText(
                text: type.messageText,
                style: .centeredBody
            )
        )
        
        bag += stackView.addArangedSubview(body) { view in
            view.snp.makeConstraints { make in
                make.width.lessThanOrEqualTo(containerView.snp.width).inset(20)
            }
        }
        
        let buttonContainer = UIView()

        let button = Button(
            title: type.buttonText,
            type: type.buttonType
        )
        
        bag += buttonContainer.add(button)
        stackView.addArrangedSubview(buttonContainer)
        
        buttonContainer.snp.makeConstraints { make in
            make.height.equalTo(button.type.height())
        }
        
        bag += events.wasAdded.delay(by: 0.5).animated(style: SpringAnimationStyle.heavyBounce()) {
            containerView.alpha = 1
            containerView.transform = CGAffineTransform.identity
        }
        
        bag += events.removeAfter.set { _ in
            return 1
        }
        
        return (containerView, Future { completion in
            bag += button.onTapSignal.onValue {
                completion(.success)
            }
            
            return DelayedDisposer(bag, delay: 1)
        })
    }
}
