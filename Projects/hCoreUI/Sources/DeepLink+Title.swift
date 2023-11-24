import Form
import Foundation
import UIKit
//
//  DeepLink+Title.swift
//  hCoreUI
//
//  Created by Sladan Nimcevic on 2023-11-22.
//  Copyright © 2023 Hedvig. All rights reserved.
//
import hCore

extension DeepLink {
    public var title: NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(
            styledText: StyledText(
                text: wholeText,
                style: UIColor.brandStyle(.chatMessage)
            )
        )
        let range = (wholeText as NSString).range(of: importantText)
        attributedText.addAttribute(
            .foregroundColor,
            value: UIColor.brandStyle(.chatMessageImportant).color,
            range: range
        )
        return attributedText
    }
}
