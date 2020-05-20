//
//  ReferralsInvitationLeftIcon.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-03.
//

import Flow
import Foundation
import UIKit
import hCore

struct ReferralsInvitationLeftIcon {}

extension ReferralsInvitationLeftIcon: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let view = Icon(icon: Asset.pinkCircularCross, iconWidth: 16)
        return (view, NilDisposer())
    }
}
