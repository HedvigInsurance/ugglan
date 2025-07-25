import SwiftUI
import hCore
import hCoreUI

struct HelpCenterPill: View {
    private let title: String
    private let color: PillColor

    public init(
        title: String,
        color: PillColor
    ) {
        self.title = title
        self.color = color
    }

    var body: some View {
        hPill(text: title, color: color)
            .hFieldSize(.small)
    }
}

#Preview {
    HelpCenterPill(title: "title", color: .pink)
}
