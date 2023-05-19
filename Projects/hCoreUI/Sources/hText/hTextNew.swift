import Combine
import Foundation
import SwiftUI
import UIKit
import hCore

private struct EnvironmentDefaultHTextStyleNew: EnvironmentKey {
    static let defaultValue: HFontTextStyle? = nil
}

extension EnvironmentValues {
    public var defaultHTextStyleNew: HFontTextStyle? {
        get { self[EnvironmentDefaultHTextStyleNew.self] }
        set { self[EnvironmentDefaultHTextStyleNew.self] = newValue }
    }
}

extension View {
    public func hTextStyleNew(_ style: HFontTextStyle? = nil) -> some View {
        self.environment(\.defaultHTextStyleNew, style)
    }
}
