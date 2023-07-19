import Foundation
import SwiftUI
import hCore

public enum GradientType: Equatable {
    case none, home
    case profile

    public func colors(for scheme: ColorScheme) -> [Color] {
        switch self {
        case .none:
            return [
                Color(.brandNew(.primaryBackground(scheme == .dark))),
                Color(.brandNew(.primaryBackground(scheme == .dark))),
                Color(.brandNew(.primaryBackground(scheme == .dark))),
            ]
        case .home:
            switch scheme {
            case .dark:
                return [
                    Color(red: 0.00, green: 0.00, blue: 0.00, opacity: 1.00),
                    Color(red: 0.11, green: 0.15, blue: 0.19, opacity: 1.00),
                    Color(red: 0.20, green: 0.13, blue: 0.12, opacity: 1.00),
                ]
            default:
                return [
                    Color(red: 0.75, green: 0.79, blue: 0.85, opacity: 1.00),
                    Color(red: 0.93, green: 0.80, blue: 0.67, opacity: 1.00),
                    Color(red: 0.96, green: 0.96, blue: 0.96, opacity: 1.00),
                ]
            }
        case .profile:
            switch scheme {
            case .dark:
                return [
                    Color(red: 0.00, green: 0.00, blue: 0.00, opacity: 1.00),
                    Color(red: 0.06, green: 0.06, blue: 0.02, opacity: 1.00),
                    Color(red: 0.12, green: 0.11, blue: 0.04, opacity: 1.00),
                ]
            default:
                return [
                    Color(red: 0.77, green: 0.87, blue: 0.93, opacity: 1.00),
                    Color(red: 0.87, green: 0.93, blue: 0.95, opacity: 1.00),
                    Color(red: 0.96, green: 0.96, blue: 0.96, opacity: 1.00),
                ]
            }
        }
    }
}
