import SwiftUI

public struct CardStack<Data, Content>: View
where Data: RandomAccessCollection, Data.Element: Identifiable, Content: View {
    @State private var currentIndex: Double = 0.0
    @State private var previousIndex: Double = 0.0
    @State private var swippingLeft = false
    private let data: Data
    @ViewBuilder private let content: (Data.Element) -> Content
    @Binding var finalCurrentIndex: Int

    public init(
        _ data: Data,
        currentIndex: Binding<Int> = .constant(0),
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.content = content
        _finalCurrentIndex = currentIndex
    }

    public var body: some View {
        ZStack {
            ForEach(Array(data.enumerated()), id: \.element.id) { (index, element) in
                content(element)
                    .zIndex(zIndex(for: index))
                    .offset(x: xOffset(for: index), y: 0)
                    .scaleEffect(scale(for: index), anchor: .center)
                    .rotationEffect(.degrees(rotationDegrees(for: index)))
            }
        }
        .highPriorityGesture(dragGesture)
        .padding(.horizontal, getPadding())
    }

    private func getPadding() -> CGFloat {
        let cardSpacing: CGFloat = 10.0
        let maxVisibleCards: CGFloat = 4.0
        let visibleCount = min(CGFloat(data.count - 1), maxVisibleCards)
        return visibleCount * cardSpacing * (1.0 - (0.1 * visibleCount))
    }
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                swippingLeft = value.translation.width < 0
                withAnimation(.interactiveSpring()) {
                    let x = (value.translation.width / 300) - previousIndex
                    self.currentIndex = -x
                }
            }
            .onEnded { value in
                self.snapToNearestAbsoluteIndex(value.predictedEndTranslation)
                self.previousIndex = self.currentIndex
            }
    }

    private func snapToNearestAbsoluteIndex(_ predictedEndTranslation: CGSize) {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 40)) {
            let translation = predictedEndTranslation.width
            if abs(translation) > 200 {
                if translation > 0 {
                    self.goTo(round(self.previousIndex) - 1)
                } else {
                    self.goTo(round(self.previousIndex) + 1)
                }
            } else {
                self.currentIndex = round(currentIndex)
            }
        }
    }

    private func goTo(_ index: Double) {
        let maxIndex = Double(data.count - 1)
        if index < 0 {
            self.currentIndex = 0
        } else if index > maxIndex {
            self.currentIndex = maxIndex
        } else {
            self.currentIndex = index
        }
        self.finalCurrentIndex = Int(index)
    }

    private func zIndex(for index: Int) -> Double {
        let value: Double = {
            let totalCount = data.count
            let maxIndex = totalCount - 1

            if swippingLeft {
                if (Double(index) + 0.5) < currentIndex {
                    return -Double(totalCount - index)
                } else {
                    return Double(totalCount - index)
                }
            } else {
                // Swiping right logic
                // Special case: at the end of the stack, show all cards naturally
                if currentIndex > Double(maxIndex) - 0.5 {
                    return Double(index)
                }

                // Calculate which card is currently active
                let activeCard = Int(round(currentIndex))

                if index > activeCard {
                    // Cards after the active card go behind (negative z-index)
                    return -Double(index - activeCard)
                } else if index == activeCard {
                    // Active card gets highest z-index (except when at the first card)
                    if activeCard == 0 {
                        return 0
                    } else {
                        return Double(maxIndex)
                    }
                } else {
                    // Cards before the active card are in the stack below
                    return Double(maxIndex) - Double(activeCard - index)
                }
            }
        }()

        return value
    }

    private func xOffset(for index: Int) -> CGFloat {
        if swippingLeft {
            let topCardProgress = currentPosition(for: index)
            let padding = 20.0
            let x = ((CGFloat(index) - currentIndex) * padding)
            if topCardProgress > 0 && topCardProgress < 0.99 && index < (data.count - 1) {
                let value = x * swingOutMultiplier(topCardProgress)
                return value
            }
            return x
        } else {
            let topCardProgress = currentPosition(for: index)
            let padding = 20.0
            let x = ((CGFloat(index) - currentIndex) * padding)
            if topCardProgress > -1 && topCardProgress < 0 && index < (data.count) {
                let value = x * swingOutMultiplier(topCardProgress)
                return -value
            }
            return x
        }
    }

    private func scale(for index: Int) -> CGFloat {
        1.0 - (0.1 * abs(currentPosition(for: index)))
    }

    private func rotationDegrees(for index: Int) -> Double {
        if swippingLeft {
            let topCardProgress = currentPosition(for: index)
            let x = -topCardProgress * 2
            if topCardProgress > 0 && topCardProgress < 0.99 && index < (data.count - 1) {
                let value = x * swingOutMultiplier(topCardProgress)
                return value
            }
            return x
        } else {
            let topCardProgress = currentPosition(for: index)
            let x = -topCardProgress * 2
            if topCardProgress > -1 && topCardProgress < 0 && index < (data.count) {
                let value = x * swingOutMultiplier(topCardProgress)
                return -value
            }
            return x
        }
    }

    private func currentPosition(for index: Int) -> Double {
        currentIndex - Double(index)
    }

    private func swingOutMultiplier(_ progress: Double) -> Double {
        sin(Double.pi * progress) * 10
    }
}
