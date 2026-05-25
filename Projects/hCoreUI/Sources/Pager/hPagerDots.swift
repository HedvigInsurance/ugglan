import SwiftUI

public struct hPagerDots: View {
    public var currentIndex: Int

    public var totalCount: Int

    @hColorBuilder func circleColor(_ index: Int) -> some hColor {
        if index == currentIndex {
            hFillColor.Opaque.primary
        } else {
            hSurfaceColor.Translucent.secondary
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
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0..<totalCount, id: \.self) { index in
                        Circle()
                            .fill(circleColor(index))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.horizontal, .padding8)
                .frame(minWidth: proxy.size.width)
            }
            .scrollDisabled(true)
        }
        .frame(height: 6)
    }
}

public struct hPagerDotsBinded: View {
    @Binding var currentIndex: Int

    public var totalCount: Int

    @hColorBuilder
    func circleColor(_ index: Int) -> some hColor {
        if index == currentIndex {
            hFillColor.Opaque.primary
        } else {
            hSurfaceColor.Translucent.secondary
        }
    }

    public init(
        currentIndex: Binding<Int>,
        totalCount: Int
    ) {
        _currentIndex = currentIndex
        self.totalCount = totalCount
    }

    public var body: some View {
        GeometryReader { proxy in
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<totalCount, id: \.self) { index in
                            Circle()
                                .fill(circleColor(index))
                                .frame(width: 6, height: 6)
                                .id(index)
                        }
                    }
                    .padding(.horizontal, .padding8)
                    .frame(minWidth: proxy.size.width)
                }
                .scrollDisabled(true)
                .onChange(of: currentIndex) { newValue in
                    withAnimation {
                        scrollProxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
        .frame(height: 6)
    }
}
