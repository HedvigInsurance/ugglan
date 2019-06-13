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
    let imageUrl: String
}

extension WhatsNewPagerScreen: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()
        
        let viewController = UIViewController()
        
        let view = UIView()
        
        let containerView = UIStackView()
        containerView.alignment = .center
        containerView.axis = .vertical
        containerView.spacing = 8
        containerView.isLayoutMarginsRelativeArrangement = true
        
        let image = RemoteVectorIcon(threaded: true)
        image.pdfUrlStringSignal.value = imageUrl
        
        bag += containerView.addArranged(image) { imageView in
            imageView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                
                if (UIScreen.main.bounds.width <= 320) {
                    make.width.equalToSuperview().multipliedBy(0.8)
                } else {
                    make.width.equalToSuperview()
                }
            }
        }
        
        let spacing = Spacing(height: 30)
        bag += containerView.addArranged(spacing)
        
        let titleLabel = MultilineLabel(styledText: StyledText(
            text: title,
            style: .standaloneLargeTitle
        ))
        
        bag += containerView.addArranged(titleLabel) { titleLabelView in
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
        
        bag += containerView.addArranged(bodyLabel) { bodyLabelView in
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
        
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(24)
            make.centerX.centerY.equalToSuperview()
            make.bottom.equalTo(0)
        }
        
        viewController.view = view
        
        return (viewController, bag)
    }
}
