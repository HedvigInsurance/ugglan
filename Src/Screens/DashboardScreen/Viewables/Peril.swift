//
//  Peril.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-04.
//

import DeviceKit
import Flow
import Form
import Foundation
import UIKit

struct Peril {
    let title: String
    let id: String
    let description: String
    let presentingViewController: UIViewController

    init(title: String, id: String, description: String, presentingViewController: UIViewController) {
        self.title = title
        self.id = id
        self.description = description
        self.presentingViewController = presentingViewController
    }
}

extension Peril {
    static func iconAsset(for value: String) -> ImageAsset {
        switch value {
        case "ME.LEGAL":
            return Asset.meLegalTrouble
        case "ME.ASSAULT":
            return Asset.meAssault
        case "ME.TRAVEL.SICK":
            return Asset.meSick
        case "ME.TRAVEL.LUGGAGE.DELAY":
            return Asset.meDelayedLuggage
        case "HOUSE.BRF.FIRE", "HOUSE.RENT.FIRE", "HOUSE.SUBLET.BRF.FIRE", "HOUSE.SUBLET.RENT.FIRE":
            return Asset.houseFire
        case "HOUSE.BRF.APPLIANCES", "HOUSE.RENT.APPLIANCES", "HOUSE.SUBLET.BRF.APPLIANCES", "HOUSE.SUBLET.RENT.APPLIANCES":
            return Asset.houseAppliances
        case "HOUSE.BRF.WEATHER", "HOUSE.RENT.WEATHER", "HOUSE.SUBLET.BRF.WEATHER", "HOUSE.SUBLET.RENT.WEATHER":
            return Asset.houseWeather
        case "HOUSE.BRF.WATER", "HOUSE.RENT.WATER", "HOUSE.SUBLET.BRF.WATER", "HOUSE.SUBLET.RENT.WATER":
            return Asset.houseWaterLeak
        case "HOUSE.BREAK-IN":
            return Asset.houseBreakIn
        case "HOUSE.DAMAGE":
            return Asset.houseVandalism
        case "STUFF.CARELESS":
            return Asset.stuffCareless
        case "STUFF.THEFT":
            return Asset.stuffTheft
        case "STUFF.DAMAGE":
            return Asset.stuffDamage
        case "STUFF.BRF.FIRE", "STUFF.RENT.FIRE", "STUFF.SUBLET.BRF.FIRE", "STUFF.SUBLET.RENT.FIRE":
            return Asset.stuffFire
        case "STUFF.BRF.WATER", "STUFF.RENT.WATER", "STUFF.SUBLET.BRF.WATER", "STUFF.SUBLET.RENT.WATER":
            return Asset.stuffWaterLeak
        case "STUFF.BRF.WEATHER", "STUFF.RENT.WEATHER", "STUFF.SUBLET.BRF.WEATHER", "STUFF.SUBLET.RENT.WEATHER":
            return Asset.stuffWeather
        default:
            return Asset.houseBreakIn
        }
    }
}

extension Peril: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (Peril) -> Disposable) {
        let perilView = UIControl()

        return (perilView, { peril in
            perilView.subviews.forEach { view in
                view.removeFromSuperview()
            }

            let bag = DisposeBag()

            let perilIcon = Icon(icon: Peril.iconAsset(for: peril.id), iconWidth: 40)
            
            perilView.addSubview(perilIcon)
            perilIcon.snp.makeConstraints { make in
                make.centerX.top.equalToSuperview()
            }

            let perilTitleLabel = MultilineLabel(styledText: StyledText(text: peril.title, style: .perilTitle))
            bag += perilView.add(perilTitleLabel) { titleLabel in
                titleLabel.textAlignment = .center

                bag += perilIcon.didLayoutSignal.onValue {
                    titleLabel.snp.makeConstraints { make in
                        make.top.equalTo(perilIcon.frame.height + 5)
                        make.centerX.equalToSuperview()
                        make.width.equalTo(50)
                    }
                }

                titleLabel.sizeToFit()
            }
            
            let touchDownDateSignal = ReadWriteSignal<Date>(Date())
            
            bag += perilView
                .signal(for: .touchDown)
                .map { Date() }
                .bindTo(touchDownDateSignal)
            
            bag += perilView.signal(for: .touchUpInside).feedback(type: .impactLight)
            
            bag += perilView.signal(for: .touchDown).animated(style: SpringAnimationStyle.lightBounce()) { _ in
                perilView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
            
            bag += merge(
                perilView.signal(for: .touchUpInside),
                perilView.signal(for: .touchUpOutside),
                perilView.signal(for: .touchCancel)
                ).withLatestFrom(touchDownDateSignal.atOnce().plain())
                .delay(by: { _, date in date.timeIntervalSinceNow < -0.2 ? 0 : 0.2 })
                .animated(style: SpringAnimationStyle.lightBounce()) { _ in
                    perilView.transform = CGAffineTransform.identity
            }
            
            bag += perilView.signal(for: .touchUpInside).onValue { _ in
                let title = peril.title.replacingOccurrences(of: "-\n", with: "")

                peril.presentingViewController.present(
                    DraggableOverlay(
                        presentable: PerilInformation(title: title, description: peril.description, icon: Peril.iconAsset(for: peril.id)),
                        presentationOptions: [.defaults, .prefersLargeTitles(false), .largeTitleDisplayMode(.never), .prefersNavigationBarHidden(true)]
                    )
                )
            }

            return bag
        })
    }
}
