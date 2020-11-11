import Foundation
import UIKit

extension ContractRow {
    var gradientColors: [UIColor] {
        switch type {
        case .norwegianHome, .swedishApartment, .danishHome:
            return [
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.42, green: 0.30, blue: 0.21, alpha: 1.00)
                    }

                    return UIColor(red: 0.984, green: 0.843, blue: 0.925, alpha: 1)
                }),
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.25, green: 0.46, blue: 0.68, alpha: 1.00)
                    }

                    return UIColor(red: 0.894, green: 0.871, blue: 0.969, alpha: 1)
                }),
            ]
        case .swedishHouse:
            return [
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.51, green: 0.33, blue: 0.16, alpha: 1.00)
                    }

                    return UIColor(red: 0.83, green: 0.81, blue: 0.80, alpha: 1.00)
                }),
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.80, green: 0.48, blue: 0.48, alpha: 1.00)
                    }

                    return UIColor(red: 0.89, green: 0.80, blue: 0.81, alpha: 1.00)
                }),
            ]
        case .norwegianTravel:
            return [
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.25, green: 0.46, blue: 0.68, alpha: 1.00)
                    }

                    return UIColor(red: 0.73, green: 0.69, blue: 0.89, alpha: 1.00)
                }),
                UIColor(dynamic: { trait -> UIColor in
                    if trait.userInterfaceStyle == .dark {
                        return UIColor(red: 0.63, green: 0.47, blue: 0.33, alpha: 1.00)
                    }

                    return UIColor(red: 0.97, green: 0.73, blue: 0.57, alpha: 1.00)
                }),
            ]
        }
    }

    var orbTintColor: UIColor {
        guard isContractActivated else {
            return .clear
        }

        switch type {
        case .norwegianHome, .swedishApartment, .danishHome:
            return UIColor(dynamic: { trait -> UIColor in
                if trait.userInterfaceStyle == .dark {
                    return UIColor(red: 0.80, green: 0.71, blue: 0.51, alpha: 1.00)
                }

                return UIColor(red: 0.937, green: 0.918, blue: 0.776, alpha: 1)
            })
        case .swedishHouse:
            return UIColor(dynamic: { trait -> UIColor in
                if trait.userInterfaceStyle == .dark {
                    return UIColor(red: 0.93, green: 0.58, blue: 0.37, alpha: 1.00)
                }

                return UIColor(red: 0.97, green: 0.73, blue: 0.57, alpha: 1.00)
            })
        case .norwegianTravel:
            return UIColor(dynamic: { trait -> UIColor in
                if trait.userInterfaceStyle == .dark {
                    return UIColor(red: 0.78, green: 0.68, blue: 0.54, alpha: 1.00)
                }

                return UIColor(red: 0.89, green: 0.80, blue: 0.81, alpha: 1.00)
            })
        }
    }

    var gradientLayer: CAGradientLayer? {
        guard isContractActivated else {
            return nil
        }

        let layer = CAGradientLayer()
        layer.colors = gradientColors.map { $0.cgColor }
        layer.locations = [0, 1]

        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 0.0)

        return layer
    }
}
