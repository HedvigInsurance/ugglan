import Foundation
import SwiftUI

struct WithTitle: ViewModifier {
    let titleParts: [String]

    init(title: String) {
        self.titleParts = Array(title.split(separator: "\n")).map({ String($0) })
    }
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(alignment: .center) {
                        ForEach(titleParts, id: \.self) { title in
                            hText(title)
                        }
                    }
                }
            }
    }
}

extension View {
    public func withNavigation(title: String) -> some View {
        modifier(WithTitle(title: title))
    }
}
