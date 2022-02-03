//
//  ConfigureForeverTabBarItem.swift
//  Forever
//
//  Created by Sam Pettersson on 2022-02-02.
//  Copyright © 2022 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import UIKit
import Flow
import hCore
import hCoreUI

extension JourneyPresentation {
    public var configureForeverTabBarItem: some JourneyPresentation {
        configureTabBarItemWithDot(
            ForeverStore.self,
            tabBarItem: UITabBarItem(
                title: L10n.tabReferralsTitle,
                image: Asset.tab.image,
                selectedImage: Asset.tabActive.image
            )) { state in
                !state.hasSeenFebruaryCampaign
            }
    }
}
