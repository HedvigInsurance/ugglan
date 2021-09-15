//
//  InvertColorSchemeModifier.swift
//  InvertColorSchemeModifier
//
//  Created by Sam Pettersson on 2021-09-15.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI

struct InvertColorSchemeModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content.colorScheme(colorScheme == .dark ? .light : .dark)
    }
}

extension View {
    /// sets color scheme to the opposite of what it was previously
    public var invertColorScheme: some View {
        self.modifier(InvertColorSchemeModifier())
    }
}
