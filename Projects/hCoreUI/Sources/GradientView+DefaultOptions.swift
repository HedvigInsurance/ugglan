import CoreGraphics
import Flow
import UIKit
import hGraphQL

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
            gradientOption: Contract.GradientOption,
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

        public func applySettings(orbLayer: CAGradientLayer, traitCollection: UITraitCollection) {
            var colors = [UIColor]()

            switch (preset, traitCollection.userInterfaceStyle) {
            case (.insuranceOne, .light):
                colors.append(UIColor(red: 0.937, green: 0.918, blue: 0.776, alpha: 1))
            case (.insuranceOne, .dark):
                colors.append(UIColor(red: 0.796, green: 0.71, blue: 0.514, alpha: 1))
            case (.insuranceTwo, .light):
                colors.append(UIColor(red: 0.886, green: 0.8, blue: 0.808, alpha: 1))
            case (.insuranceTwo, .dark):
                colors.append(UIColor(red: 0.776, green: 0.678, blue: 0.541, alpha: 1))
            case (.insuranceThree, .light):
                colors.append(UIColor(red: 0.973, green: 0.726, blue: 0.574, alpha: 1))
            case (.insuranceThree, .dark):
                colors.append(UIColor(red: 0.925, green: 0.584, blue: 0.374, alpha: 1))
            case (.insuranceFour, .light):
                colors.append(UIColor(red: 0.57, green: 0.85, blue: 0.94, alpha: 1))
            case (.insuranceFour, .dark):
                colors.append(UIColor(red: 0.57, green: 0.85, blue: 0.94, alpha: 1))
            default:
                colors.append(.white)
            }

            let alphaWhite = UIColor.white.withAlphaComponent(0.0)
            colors.append(alphaWhite)

            orbLayer.type = .radial
            orbLayer.colors = colors.map { $0.cgColor }
            orbLayer.locations = [0, 1.0]
            orbLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
            orbLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        }

        public func backgroundColors(traitCollection: UITraitCollection) -> [UIColor] {
            switch (preset, traitCollection.userInterfaceStyle) {
            case (.insuranceOne, .light):
                return [
                    UIColor(red: 0.921, green: 0.825, blue: 0.834, alpha: 1),
                    UIColor(red: 0.85, green: 0.82, blue: 0.946, alpha: 1),
                ]
            case (.insuranceOne, .dark):
                return [
                    UIColor(red: 0.416, green: 0.302, blue: 0.212, alpha: 1),
                    UIColor(red: 0.247, green: 0.463, blue: 0.682, alpha: 1),
                ]
            case (.insuranceTwo, .light):
                return [
                    UIColor(red: 0.725, green: 0.686, blue: 0.89, alpha: 1),
                    UIColor(red: 0.973, green: 0.725, blue: 0.573, alpha: 1),
                ]
            case (.insuranceTwo, .dark):
                return [
                    UIColor(red: 0.247, green: 0.463, blue: 0.682, alpha: 1),
                    UIColor(red: 0.627, green: 0.467, blue: 0.325, alpha: 1),
                ]
            case (.insuranceThree, .light):
                return [
                    UIColor(red: 0.831, green: 0.812, blue: 0.8, alpha: 1),
                    UIColor(red: 0.886, green: 0.8, blue: 0.808, alpha: 1),
                ]

            case (.insuranceThree, .dark):
                return [
                    UIColor(red: 0.512, green: 0.326, blue: 0.162, alpha: 1),
                    UIColor(red: 0.796, green: 0.481, blue: 0.481, alpha: 1),
                ]
            case (.insuranceFour, .light):
                return [
                    UIColor(red: 0.96, green: 0.68, blue: 0.71, alpha: 1),
                    UIColor(red: 0.97, green: 0.98, blue: 0.87, alpha: 1),
                ]
            case (.insuranceFour, .dark):
                return [
                    UIColor(red: 0.96, green: 0.68, blue: 0.71, alpha: 1),
                    UIColor(red: 0.97, green: 0.98, blue: 0.87, alpha: 1),
                ]
            default:
                return []
            }
        }
    }

    public enum Preset: CaseIterable {
        case insuranceOne
        case insuranceTwo
        case insuranceThree
        case insuranceFour

        public static var random: Self {
            Self.allCases.shuffled().randomElement()!
        }
    }
}

extension Contract.GradientOption {
    var preset: GradientView.Preset {
        switch self {
        case .one:
            return .insuranceOne
        case .two:
            return .insuranceTwo
        case .three:
            return .insuranceThree
        case .four:
            return .insuranceFour
        }
    }
}
