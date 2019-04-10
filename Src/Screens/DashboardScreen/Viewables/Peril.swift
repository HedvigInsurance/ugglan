//
//  Peril.swift
//  ugglan
//
//  Created by Axel Backlund on 2019-04-04.
//

import Flow
import Form
import Foundation
import UIKit

struct Peril {
    let title: String
    let id: String
    
    init(title: String, id: String) {
        self.title = title
        self.id = id
    }
}

// query chatactions

extension Peril: Reusable {
    
    static func makeAndConfigure() -> (make: UIView, configure: (Peril) -> Disposable) {
        let perilView = UIView()
        
        func perilIconAsset(for value: String) -> ImageAsset {
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
        
        return (perilView, { peril in
            perilView.subviews.forEach({ view in
                view.removeFromSuperview()
            })
            
            let bag = DisposeBag()
            
            let perilIcon = Icon(icon: perilIconAsset(for: peril.id), iconWidth: 40)
            perilView.addSubview(perilIcon)
            perilIcon.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
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
            
            return bag
        })
    }
}
