import CoreGraphics
import Flow
import UIKit
import hGraphQL
import hCore

extension GradientView {
    public struct GradientOption: Equatable {
        public init(
            preset: GradientView.Preset,
            shouldShimmer: Bool = true,
            shouldAnimate: Bool = true
        ) {
            self.preset = preset
            self.shouldShimmer = shouldShimmer
            self.shouldAnimate = shouldAnimate
        }

        public init(
            gradientOption: PillowType,
            shouldShimmer: Bool = true,
            shouldAnimate: Bool = true
        ) {
            self.preset = gradientOption.preset
            self.shouldShimmer = shouldShimmer
            self.shouldAnimate = shouldAnimate
        }

        public let shouldShimmer: Bool
        public let shouldAnimate: Bool

        public let preset: Preset

        public var locations: [NSNumber] {
            [0, 1]
        }

        public var startPoint: CGPoint {
            CGPoint(x: 0.25, y: 0.5)
        }

        public var endPoint: CGPoint {
            CGPoint(x: 0.75, y: 0.5)
        }

        public var transform: CATransform3D {
            CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 0, c: 0, d: 2.94, tx: 0, ty: -0.97))
        }

        public func backgroundColors(traitCollection: UITraitCollection) -> [UIColor] {
            switch (preset, traitCollection.userInterfaceStyle) {
            case (.home, .light):
                return [
                    UIColor(red: 0.921, green: 0.825, blue: 0.834, alpha: 1),
                    UIColor(red: 0.85, green: 0.82, blue: 0.946, alpha: 1),
                ]
            case (.home, .dark):
                return [
                    UIColor(red: 0.416, green: 0.302, blue: 0.212, alpha: 1),
                    UIColor(red: 0.247, green: 0.463, blue: 0.682, alpha: 1),
                ]
            case (.accident, .light):
                return [
                    UIColor(red: 0.725, green: 0.686, blue: 0.89, alpha: 1),
                    UIColor(red: 0.973, green: 0.725, blue: 0.573, alpha: 1),
                ]
            case (.accident, .dark):
                return [
                    UIColor(red: 0.247, green: 0.463, blue: 0.682, alpha: 1),
                    UIColor(red: 0.627, green: 0.467, blue: 0.325, alpha: 1),
                ]
            case (.house, .light):
                return [
                    UIColor(red: 0.831, green: 0.812, blue: 0.8, alpha: 1),
                    UIColor(red: 0.886, green: 0.8, blue: 0.808, alpha: 1),
                ]

            case (.house, .dark):
                return [
                    UIColor(red: 0.512, green: 0.326, blue: 0.162, alpha: 1),
                    UIColor(red: 0.796, green: 0.481, blue: 0.481, alpha: 1),
                ]
            case (.travel, .light):
                return [
                    UIColor(red: 0.91, green: 0.84, blue: 0.60, alpha: 1),
                    UIColor(red: 0.93, green: 0.80, blue: 0.80, alpha: 1),
                ]
            case (.travel, .dark):
                return [
                    UIColor(red: 0.40, green: 0.26, blue: 0.06, alpha: 1),
                    UIColor(red: 0.53, green: 0.31, blue: 0.53, alpha: 1),
                ]
            case (.car, .light):
                return [
                    UIColor(red: 0.95, green: 0.55, blue: 0.67, alpha: 1),
                    UIColor(red: 0.84, green: 0.78, blue: 0.90, alpha: 1),
                ]
            case (.car, .dark):
                return [
                    UIColor(red: 0.67, green: 0.47, blue: 0.65, alpha: 1),
                    UIColor(red: 0.44, green: 0.39, blue: 0.69, alpha: 1),
                ]
            case (.pet, .light):
                return [
                    UIColor(red: 0.29, green: 0.45, blue: 0.61, alpha: 1),
                    UIColor(red: 0.89, green: 0.96, blue: 0.78, alpha: 1),
                ]
            case (.pet, .dark):
                return [
                    UIColor(red: 0.19, green: 0.34, blue: 0.49, alpha: 1),
                    UIColor(red: 0.72, green: 0.82, blue: 0.58, alpha: 1),
                ]
            default:
                return []
            }
        }
    }

    public enum Preset: CaseIterable {
        case home
        case accident
        case house
        case travel
        case car
        case pet
        case unknown

        public static var random: Self {
            Self.allCases.shuffled().randomElement()!
        }
    }
}

extension PillowType {
    public var preset: GradientView.Preset {
        switch self {
        case .accident:
            return .accident
        case .car:
            return .car
        case .cat:
            return .pet
        case .dog:
            return .pet
        case .home:
            return .home
        case .homeOwner:
            return .home
        case .pet:
            return .pet
        case .rental:
            return .home
        case .student:
            return .home
        case .travel:
            return .travel
        case .villa:
            return .house
        case .unknown:
            return .unknown
        }
    }
}
