import SwiftUI

enum HelpViewSource {
    case homeView
    case topicView
    case questionView

    var title: String {
        switch self {
        case .homeView:
            return "home view"
        case .topicView:
            return "topic view"
        case .questionView:
            return "question view"
        }
    }
}
