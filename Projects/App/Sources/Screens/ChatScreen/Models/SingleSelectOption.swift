import Foundation

struct SingleSelectOption: Equatable {
    let type: OptionType
    let text: String
    let value: String

    enum ViewType: Equatable {
        case dashboard, offer

        static func from(rawValue: String) -> ViewType {
            switch rawValue {
            case "DASHBOARD":
                return .dashboard
            case "OFFER":
                return .offer
            default:
                return .dashboard
            }
        }
    }

    enum OptionType: Equatable {
        case selection, link(view: ViewType), login
    }
}
