import Foundation
import SwiftUI
import UIKit
import hCore

public enum GradientType {
    case none, home, insurance, forever, profile

    public func colors(for scheme: ColorScheme) -> [Color] {
        switch self {
        case .none:
            return [
                Color(.brand(.primaryBackground(scheme == .dark))),
                Color(.brand(.primaryBackground(scheme == .dark))),
                Color(.brand(.primaryBackground(scheme == .dark))),
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
        case .insurance:
            switch scheme {
            case .dark:
                return [
                    Color(red: 0.00, green: 0.00, blue: 0.00, opacity: 1.00),
                    Color(red: 0.04, green: 0.09, blue: 0.10, opacity: 1.00),
                    Color(red: 0.10, green: 0.18, blue: 0.20, opacity: 1.00),
                ]
            default:
                return [
                    Color(red: 0.95, green: 0.85, blue: 0.75, opacity: 1.00),
                    Color(red: 0.96, green: 0.91, blue: 0.86, opacity: 1.00),
                    Color(red: 0.96, green: 0.96, blue: 0.96, opacity: 1.00),
                ]
            }
        case .forever:
            switch scheme {
            case .dark:
                return [
                    Color(red: 0.00, green: 0.00, blue: 0.00, opacity: 1.00),
                    Color(red: 0.07, green: 0.07, blue: 0.07, opacity: 1.00),
                    Color(red: 0.15, green: 0.15, blue: 0.15, opacity: 1.00),
                ]
            default:
                return [
                    Color(red: 0.83, green: 0.83, blue: 0.83, opacity: 1.00),
                    Color(red: 0.90, green: 0.90, blue: 0.90, opacity: 1.00),
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
