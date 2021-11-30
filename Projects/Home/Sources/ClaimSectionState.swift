import SwiftUI
import Combine
import UIKit
import hGraphQL

class ClaimSectionState: NSObject, ObservableObject, UIScrollViewDelegate {
    internal init(scrollView: UIScrollView? = nil, claims: [Claim], lastOffset: CGFloat = 0.0) {
        self.scrollView = scrollView
        self.claims = claims
        self.lastOffset = lastOffset
    }
    
    var scrollView: UIScrollView? {
        didSet {
            scrollView?.delegate = self
        }
    }
    
    var claims: [Claim]
    
    private var lastOffset: CGFloat = 0.0
    
    @Published
    private (set) var frameWidth: CGFloat = 0.0
    
    @Published
    private (set) var currentIndex: Int = 0
    
    private func calculateCurrentVisibleItem() {
        let predictedIndex = ceil((scrollView?.contentOffset.x ?? 0.0) / (self.frameWidth * 0.9))
        
        let newIndex = Int(predictedIndex)
        
        guard currentIndex != newIndex else { return }
        
        currentIndex = newIndex
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cardWidth = frameWidth * 0.9
        
        let currentXOffset = (scrollView.contentOffset.x)
        
        var currentCardNumber = round(currentXOffset / cardWidth)
        
        if velocity.x > 0.1 {
            currentCardNumber += 1
        } else if velocity.x < -0.1 {
            currentCardNumber += -1
        }
        
        let contentTotalSize = scrollView.contentSize.width - CGFloat((claims.count - 1) * 8)
        
        let estimatedTotalNumber = round(contentTotalSize / cardWidth)
        
        if currentCardNumber > estimatedTotalNumber {
            currentCardNumber = estimatedTotalNumber
        } else if currentCardNumber < 0 {
            currentCardNumber = 0
        }
        
        let targetOffset = currentCardNumber * (cardWidth + 8)
        
        targetContentOffset.pointee = CGPoint(x: targetOffset, y: scrollView.contentOffset.y)
        
        currentIndex = Int(currentCardNumber)
    }
    
    func updateFrameWidth(width: CGFloat) {
        guard width != frameWidth else { return }
        
        frameWidth = width
    }
}
