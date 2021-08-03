//
//  hRow.swift
//  hCore
//
//  Created by Sam Pettersson on 2021-08-02.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import SwiftUI

enum hRowPosition {
    case top
    case middle
    case bottom
    case unique
}

private struct EnvironmentHRowPosition: EnvironmentKey {
    static let defaultValue = hRowPosition.unique
}

extension EnvironmentValues {
    var hRowPosition: hRowPosition {
        get { self[EnvironmentHRowPosition.self] }
        set { self[EnvironmentHRowPosition.self] = newValue }
    }
}

struct RowButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .background(configuration.isPressed ? Color(UIColor.brand(.primaryBackground(true))).opacity(0.1) : Color.clear)
            .animation(.easeOut(duration: 0.2).delay(configuration.isPressed ? 0 : 0.15), value: configuration.isPressed)
    }
}

public struct hRow<Content: View>: View {
    @SwiftUI.Environment(\.hRowPosition) var position: hRowPosition
    
    var content: Content
        
    public init(@ViewBuilder _ builder: () -> Content) {
        self.content = builder()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                content
            }
            .padding([.horizontal], 15)
            .padding([.vertical], 15)
            if position == .middle || position == .top {
                hRowDivider()
            }
        }
    }
}

public extension hRow {
    func onTap(_ onTap: @escaping () -> Void) -> some View {
        SwiftUI.Button(action: onTap, label: {
            self
        }).buttonStyle(RowButtonStyle())
    }
}
