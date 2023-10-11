import SwiftUI

public struct hPagerDots: View {
    public var currentIndex: Int

    public var totalCount: Int

    @hColorBuilder func circleColor(_ index: Int) -> some hColor {
        if index == currentIndex {
            hTextColor.primary
        } else {
            hTextColor.tertiary
        }
    }

    public init(
        currentIndex: Int,
        totalCount: Int
    ) {
        self.currentIndex = currentIndex
        self.totalCount = totalCount
    }

    public var body: some View {
        HStack {
            ForEach(0..<totalCount, id: \.self) { index in
                Circle()
                    .fill(circleColor(index))
                    .frame(width: 6, height: 6)
            }
        }
    }
}
