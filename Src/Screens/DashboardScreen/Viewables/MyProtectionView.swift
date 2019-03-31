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
            default:
                return "hej"
            }
        }
        
        func subtitleText() -> String {
            switch self {
            case .coinsured:
                return "försäkras för"
            default:
                return "hej"
            }
        }
        
        func iconAsset() -> ImageAsset {
            switch self {
            case .coinsured:
                return Asset.coinsured
            default:
                return Asset.dashboardTab
            }
        }
        
        func iconWidth() -> CGFloat {
            switch self {
            case .coinsured:
                return 70
            default:
                return 70
            }
        }
        
        func footerText() -> String {
            switch self {
            case .coinsured:
                return "Klicka på ikonerna för mer info"
            default:
                return "hej"
            }
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
        
        let containerStackView = UIStackView()
        containerStackView.axis = .horizontal
        containerStackView.alignment = .center
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.edgeInsets = UIEdgeInsets(
            top: 20,
            left: 20,
            bottom: 20,
            right: 20
        )
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 15
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowColor = UIColor.darkGray.cgColor
        
        // Large icon
        let icon = Icon(frame: .zero, icon: mode.iconAsset(), iconWidth: mode.iconWidth())
        icon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        containerStackView.addArrangedSubview(icon)
        
        /*let titleLabel = UILabel(value: mode.titleText(), style: .boldSmallTitle)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        containerStackView.addArrangedSubview(titleLabel)*/
        
        // Title+subtitle
        let titlesView = UIView()
        titlesView.backgroundColor = .blue
        titlesView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let titleLabel = UILabel(value: mode.titleText(), style: .boldSmallTitle)
        titleLabel.backgroundColor = .red
        titlesView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints({ make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.leading.equalToSuperview()
        })
        
        //let subtitleLabel = UILabel(value: mode.subtitleText(), style: .body)
        //titleStackView.addArrangedSubview(subtitleLabel)
        containerStackView.addArrangedSubview(titlesView)
        
        /*titleLabel.snp.makeConstraints( { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        })*/
        
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
        
        return (containerView, bag)
    }
}
