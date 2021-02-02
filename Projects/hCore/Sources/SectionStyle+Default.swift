//
//  SectionStyle+Default.swift
//  hCore
//
//  Created by Tarik Stafford on 2021-01-25.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Form
import UIKit

extension SectionStyle {
    public static let defaultStyle = SectionStyle(
        rowInsets: UIEdgeInsets(
            top: 10,
            left: 15,
            bottom: 10,
            right: 15
        ),
        itemSpacing: 0,
        minRowHeight: 10,
        background: .init(all: UIColor.clear.asImage()),
        selectedBackground: .init(all: UIColor.clear.asImage()),
        header: .none,
        footer: .none
    )
}
