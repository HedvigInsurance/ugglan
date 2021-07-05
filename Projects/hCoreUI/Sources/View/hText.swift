//
//  hText.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2021-07-05.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI

public struct hText: View {
	var content: String
	public init(_ content: String) { self.content = content }
	public var body: some View { Text(content).font(Fonts.font) }
}
