//
//  MyProtectionRow.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-03-29.
//

import Flow
import Form
import Foundation
import UIKit

struct MyProtectionView {
    
    enum ProtectionMode {
        case coinsured, home, items
        
        func titleText() -> String {
            switch self {
            case .coinsured:
                return String(.PROFILE_MY_COINSURED_ROW_SUBTITLE(amountCoinsured: "min sambo"))
            case .home:
                return "Islandsvägen 13"
            case .items:
                return "Mina prylar"
            }
        }
        
        func subtitleText() -> String {
            return "försäkras för"
        }
        
        func iconAsset() -> ImageAsset {
            switch self {
            case .coinsured:
                return Asset.coinsuredPlain
            case .home:
                return Asset.homePlain
            case .items:
                return Asset.itemsPlain
            }
        }
        
        func iconWidth() -> CGFloat {
            return 75
        }
        
        func footerText() -> String {
            return "Klicka på ikonerna för mer info"
        }
        
        func protections() -> [String] {
            switch self {
            case .coinsured:
                return ["ett", "två"]
            default:
                return ["hej"]
            }
        }
    }
    
    let mode: ProtectionMode
    
    //let color: ColorAsset
    
    init(
        mode: ProtectionMode
        //color: ColorAsset,
    ) {
        self.mode = mode
    }
}

extension MyProtectionView: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let stackViewEdgeInsets = UIEdgeInsets(
            top: 12,
            left: 15,
            bottom: 12,
            right: 25
        )
        
        let containerStackView = UIStackView(
            views: [],
            axis: .horizontal,
            spacing: 20,
            edgeInsets: stackViewEdgeInsets
        )
        
        containerStackView.alignment = .center
        containerStackView.isLayoutMarginsRelativeArrangement = true
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.layer.shadowOpacity = 0.14
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        
        // Large icon
        let icon = Icon(frame: .zero, icon: mode.iconAsset(), iconWidth: mode.iconWidth())
        icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        containerStackView.addArrangedSubview(icon)
        
        // Title+subtitle
        let titlesView = UIStackView()
        titlesView.axis = .vertical
        titlesView.backgroundColor = .blue
        titlesView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let titleLabel = MultilineLabel(styledText: StyledText(text: mode.titleText(), style: .rowTitle))
        bag += titlesView.addArangedSubview(titleLabel)
        
        let subtitleLabel = MultilineLabel(styledText: StyledText(text: mode.subtitleText(), style: .rowSubtitle))
        bag += titlesView.addArangedSubview(subtitleLabel)

        containerStackView.addArrangedSubview(titlesView)
        
        // Chevron down
        let chevronDown = Icon(frame: .zero, icon: Asset.chevronRight, iconWidth: 30)
        chevronDown.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi / 2)
        chevronDown.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        containerStackView.addArrangedSubview(chevronDown)
        
        containerView.addSubview(containerStackView)
        
        containerStackView.snp.makeConstraints({ make in
            make.width.height.centerX.centerY.equalToSuperview()
        })
        
        bag += containerStackView.didLayoutSignal.onValue({ _ in
            let size = containerStackView.systemLayoutSizeFitting(CGSize.zero)
            
            containerView.snp.remakeConstraints({ make in
                make.height.equalTo(size.height)
                make.width.equalTo(size.width)
            })
        })
        
        let tapGesture = UITapGestureRecognizer()
        containerView.isUserInteractionEnabled = true
        bag += containerView.install(tapGesture)
        
        bag += tapGesture.signal(forState: .ended).onValue({ _ in
            // TODO: Show details of the insurance
            print("Open up")
        })
        
        return (containerView, bag)
    }
}
