//
//  WhatsNewPagerScreen.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-12.
//

import Foundation
import Presentation
import Form
import Flow
import UIKit

struct WhatsNewPagerScreen {
    let title: String
    let paragraph: String
    let icon: RemoteVectorIcon
}

extension WhatsNewPagerScreen: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        
        let viewController = UIViewController()
                
        let containerView = UIStackView()
        containerView.alignment = .center
        containerView.axis = .horizontal
        containerView.distribution = .fill
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.edgeInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        )
        
        let innerContainerView = UIStackView()
        innerContainerView.alignment = .center
        innerContainerView.axis = .vertical
        innerContainerView.spacing = 8
        innerContainerView.isLayoutMarginsRelativeArrangement = true
        
        containerView.addArrangedSubview(innerContainerView)
        
        innerContainerView.snp.makeConstraints { make in
            make.width.centerX.equalToSuperview()
        }
        
        bag += innerContainerView.addArranged(icon) { iconView in
            iconView.snp.makeConstraints { make in
                make.width.centerX.equalToSuperview()
            }
        }
        
        let spacing = Spacing(height: 30)
        bag += innerContainerView.addArranged(spacing)
        
        let titleLabel = MultilineLabel(styledText: StyledText(
            text: title,
            style: .standaloneLargeTitle
        ))
        
        bag += innerContainerView.addArranged(titleLabel) { titleLabelView in
            titleLabelView.textAlignment = .center
            
            titleLabelView.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(100)
            }
            
            bag += titleLabel.intrinsicContentSizeSignal.onValue { size in
                titleLabelView.snp.makeConstraints { make in
                    make.height.equalTo(size.height)
                }
            }
        }
        
        let bodyLabel = MultilineLabel(styledText: StyledText(
            text: paragraph,
            style: .bodyOffBlack
        ))
        
        bag += innerContainerView.addArranged(bodyLabel) { bodyLabelView in
            bodyLabelView.textAlignment = .center
            
            bodyLabelView.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.centerX.equalToSuperview()
                make.height.equalTo(100)
            }
            
            bag += bodyLabel.intrinsicContentSizeSignal.onValue { size in
                bodyLabelView.snp.makeConstraints { make in
                    make.height.equalTo(size.height)
                }
            }
        }
        
        viewController.view = containerView
        
        bag += viewController.view.didLayoutSignal.onValue { _ in
            containerView.snp.makeConstraints { make in
                make.height.centerX.centerY.equalToSuperview()
                make.width.equalToSuperview().inset(20)
            }
        }
        
        return (viewController, bag)
    }
}
