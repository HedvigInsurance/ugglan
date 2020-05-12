//
//  ReferralsInvitationOnboardingIcon.swift
//  project
//
//  Created by Sam Pettersson on 2019-06-03.
//

import Flow
import Foundation
import UIKit
import hCore

struct ReferralsInvitationOnboardingIcon {}

extension ReferralsInvitationOnboardingIcon: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = Icon(icon: Asset.clock, iconWidth: 16)
        return (view, NilDisposer())
    }
}
