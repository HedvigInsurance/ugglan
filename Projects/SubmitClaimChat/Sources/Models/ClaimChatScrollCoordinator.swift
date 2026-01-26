import Combine
import UIKit

/// Manages scroll behavior and positioning for the claim chat interface
@MainActor
final class ClaimChatScrollCoordinator: ObservableObject {
    // MARK: - Constants
    /// Threshold ratio (0.6 = 60%) above which the input is merged with content instead of being fixed at bottom
    private let inputHeightThreshold: CGFloat = 0.6
    /// Top padding applied to content to provide spacing above the first message
    private let topPadding: CGFloat = 32

    // MARK: - Published State
    @Published var isInputScrolledOffScreen = false
    @Published var shouldMergeInputWithContent = false

    // MARK: - Properties
    var scrollViewHeight: CGFloat = 0
    var scrollViewBottomInset: CGFloat = 0
    weak var scrollView: UIScrollView? {
        didSet {
            scrollCancellable = scrollView?.publisher(for: \.contentOffset)
                .throttle(for: .milliseconds(200), scheduler: DispatchQueue.main, latest: true)
                .removeDuplicates()
                .sink(receiveValue: { [weak self] _ in
                    self?.checkForScrollOffset()
                })
        }
    }

    private var scrollCancellable: AnyCancellable?

    // MARK: - Dependencies
    private var totalStepsHeight: (() -> CGFloat)?
    private var currentStepInputHeight: (() -> CGFloat)?

    func configure(
        totalStepsHeight: @escaping () -> CGFloat,
        currentStepInputHeight: @escaping () -> CGFloat
    ) {
        self.totalStepsHeight = totalStepsHeight
        self.currentStepInputHeight = currentStepInputHeight
    }

    /// Scrolls to the bottom of the scroll view
    func scrollToBottom() {
        guard let scrollView else { return }
        let bottomOffset = CGPoint(
            x: 0,
            y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom + 40
        )
        scrollView.setContentOffset(bottomOffset, animated: true)
    }

    /// Checks if the current step input should be hidden based on scroll position
    func checkForScrollOffset() {
        guard let scrollView,
            let getTotalHeight = totalStepsHeight,
            let getInputHeight = currentStepInputHeight
        else { return }

        let inputHeight = getInputHeight()
        let totalHeight = getTotalHeight()

        // If current step bottom input part is huge, merge it with the form
        if inputHeight / scrollView.frame.size.height > inputHeightThreshold {
            shouldMergeInputWithContent = true
            return
        }

        shouldMergeInputWithContent = false

        // Calculate if input is scrolled off screen by comparing needed vs available space
        // Available height = visible area + scroll offset - content height - padding
        // This determines if there's enough room to show the input above the keyboard
        let neededHeight = inputHeight
        let availableHeight =
            scrollView.frame.size.height  // Visible scroll view height
            - scrollView.safeAreaInsets.top  // Minus top safe area
            + scrollView.contentOffset.y  // Plus scroll offset
            - totalHeight  // Minus total content height
            + scrollView.adjustedContentInset.top  // Plus content inset
            - topPadding  // Minus top padding

        isInputScrolledOffScreen = neededHeight > availableHeight
    }
}
