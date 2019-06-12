//
//  ReferralsInvitationOnboardingIcon.swift
//  project
//
//  Created by Sam Pettersson on 2019-06-03.
//

import Foundation
import Flow
import UIKit

struct ReferralsInvitationOnboardingIcon {}

extension ReferralsInvitationOnboardingIcon: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = Icon(icon: Asset.clock, iconWidth: 16)
        return (view, NilDisposer())
    }
}
