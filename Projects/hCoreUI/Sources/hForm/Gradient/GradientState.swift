import Flow
import Foundation
import SwiftUI
import hCore

public class GradientState: ObservableObject {
    public static let shared = GradientState()
    private init() {}

    private var hasAnimatedInitial = false

    @Published var oldGradientType: GradientType = .none
    @Published var gradientTypeBeforeNone: GradientType? = nil

    @Published public var gradientType: GradientType = .none {
        didSet {
            if gradientType != oldValue && oldValue != .none {
                oldGradientType = oldValue

                if gradientType == .none {
                    gradientType = oldValue
                    gradientTypeBeforeNone = oldValue
                }
            }

            if gradientType != oldValue && oldValue == .none && !hasAnimatedInitial {
                oldGradientType = oldValue
                hasAnimatedInitial = true
            }
        }
    }
}
