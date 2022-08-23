import Flow
import Foundation
import SwiftUI
import UIKit
import hCore

public class GradientState: ObservableObject {
    public static let shared = GradientState()
    private init() {}

    @Published var oldGradientType: GradientType = .none
    @Published var animate: Bool = true

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
        }
    }
}
