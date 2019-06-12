//
//  ReferralsInvitationLeftIcon.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-03.
//

import Foundation
import Flow
import UIKit

struct ReferralsInvitationLeftIcon {}

extension ReferralsInvitationLeftIcon: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = Icon(icon: Asset.pinkCircularCross, iconWidth: 16)
        return (view, NilDisposer())
    }
}
