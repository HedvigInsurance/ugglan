import SwiftUI
import Combine
import UIKit

class ClaimSectionState: NSObject, ObservableObject, UIScrollViewDelegate {
    
    var scrollView: UIScrollView? {
        didSet {
            scrollView?.delegate = self
        }
    }
    
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        calculateCurrentVisibleItem()
    }
    
    func updateFrameWidth(width: CGFloat) {
        guard width != frameWidth else { return }
        
        frameWidth = width
    }
}
