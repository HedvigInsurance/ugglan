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
    static var hasRoundedCorners: Bool = Device.current.isOneOf([
        Device.iPhoneX,
        Device.iPhoneXS,
        Device.iPhoneXSMax,
        Device.iPhoneXR,
        Device.iPadPro12Inch3,
        Device.simulator(Device.iPhoneX),
        Device.simulator(Device.iPhoneXS),
        Device.simulator(Device.iPhoneXSMax),
        Device.simulator(Device.iPhoneXR),
        Device.simulator(Device.iPadPro12Inch3),
    ])
}
