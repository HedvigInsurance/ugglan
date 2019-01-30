//
//  DeviceKit+RoundedCorners.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-18.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import DeviceKit
import Foundation

extension Device {
    static var hasRoundedCorners: Bool = Device().isOneOf([
        Device.iPhoneX,
        Device.iPhoneXs,
        Device.iPhoneXsMax,
        Device.iPhoneXr,
        Device.iPadPro12Inch3,
        Device.simulator(Device.iPhoneX),
        Device.simulator(Device.iPhoneXs),
        Device.simulator(Device.iPhoneXsMax),
        Device.simulator(Device.iPhoneXr),
        Device.simulator(Device.iPadPro12Inch3)
    ])
}
