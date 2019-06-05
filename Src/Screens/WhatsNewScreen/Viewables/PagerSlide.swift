//
//  PagerSlide.swift
//  project
//
//  Created by Gustaf Gunér on 2019-06-05.
//

import Foundation
import Form
import Flow
import UIKit

struct PagerSlide {
    let title: String
    let body: String
}

extension PagerSlide: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let view = UIView()
        
        let containerView = UIStackView()
        containerView.alignment = .center
        containerView.axis = .vertical
        containerView.spacing = 8
        containerView.isLayoutMarginsRelativeArrangement = true
        
        containerView.edgeInsets = UIEdgeInsets(
            top: 24,
            left: 24,
            bottom: 24,
            right: 24
        )
        
        let imageView = UIImageView()
        imageView.image = Asset.bonusrain.image
        
        containerView.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(270)
        }
        
        let spacing = Spacing(height: 40)
        bag += containerView.addArranged(spacing)
        
        let titleLabel = MultilineLabel(styledText: StyledText(
            text: title,
            style: .standaloneLargeTitle
        ))
        
        bag += containerView.addArranged(titleLabel) { titleLabelView in
            titleLabelView.textAlignment = .center
            
            titleLabelView.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(100)
            }
            
            bag += titleLabel.intrinsicContentSizeSignal.onValue { size in
                titleLabelView.snp.makeConstraints { make in
                    make.height.equalTo(size.height)
                }
            }
        }
        
        let bodyLabel = MultilineLabel(styledText: StyledText(
            text: body,
            style: .bodyOffBlack
        ))
        
        bag += containerView.addArranged(bodyLabel) { bodyLabelView in
            bodyLabelView.textAlignment = .center
            
            bodyLabelView.snp.makeConstraints { make in
                make.width.equalToSuperview()
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
            make.centerX.equalToSuperview()
        }
        
        return (view, bag)
    }
}
