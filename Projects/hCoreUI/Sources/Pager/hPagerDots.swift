import SwiftUI

public struct hPagerDots: View {
    public var currentIndex: Int

    public var totalCount: Int

    @hColorBuilder func circleColor(_ index: Int) -> some hColor {
        if index == currentIndex {
            hTextColor.Opaque.primary
        } else {
            hFillColor.opaqueTwo
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

public struct hPagerDotsBinded: View {
    @Binding var currentIndex: Int

    public var totalCount: Int

    @hColorBuilder
    func circleColor(_ index: Int) -> some hColor {
        if index == currentIndex {
            hTextColor.Opaque.primary
        } else {
            hFillColor.opaqueTwo
        }
    }

    public init(
        currentIndex: Binding<Int>,
        totalCount: Int
    ) {
        self._currentIndex = currentIndex
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
        .onChange(of: self.currentIndex) { index in
            let ss = index
        }
    }
}
