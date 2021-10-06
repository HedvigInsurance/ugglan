import CoreMedia
import Foundation
import QuartzCore
import UIKit

protocol AnimatedScroll {
    func setContentOffset(offset: CGPoint, timingFunction: CAMediaTimingFunction, duration: CFTimeInterval)
}

private var displayLinkKey: UInt8 = 0
private var animationStartedKey: UInt8 = 1
private var beginTimeKey: UInt8 = 2
private var beginContentOffsetKey: UInt8 = 3
private var deltaContentOffsetKey: UInt8 = 4
private var durationKey: UInt8 = 5
private var timingFunctionKey: UInt8 = 6

private func CGPointScalarMult(s: CGFloat, _ p: CGPoint) -> CGPoint { CGPoint(x: s * p.x, y: s * p.y) }

private func CGPointAdd(p: CGPoint, _ q: CGPoint) -> CGPoint { CGPoint(x: p.x + q.x, y: p.y + q.y) }

private func CGPointMinus(p: CGPoint, _ q: CGPoint) -> CGPoint { CGPoint(x: p.x - q.x, y: p.y - q.y) }

extension CAMediaTimingFunction {
    public func getControlPoint(index: UInt) -> (x: CGFloat, y: CGFloat)? {
        switch index {
        case 0...3:
            let controlPoint = UnsafeMutablePointer<Float>.allocate(capacity: 2)
            getControlPoint(at: Int(index), values: controlPoint)
            let x: Float = controlPoint[0]
            let y: Float = controlPoint[1]
            controlPoint.deallocate()
            return (CGFloat(x), CGFloat(y))
        default: return nil
        }
    }

    public var controlPoints: [CGPoint] {
        var controlPoints = [CGPoint]()
        for index in 0..<4 {
            let controlPoint = UnsafeMutablePointer<Float>.allocate(capacity: 2)
            getControlPoint(at: Int(index), values: controlPoint)
            let x: Float = controlPoint[0]
            let y: Float = controlPoint[1]
            controlPoint.deallocate()
            controlPoints.append(CGPoint(x: CGFloat(x), y: CGFloat(y)))
        }
        return controlPoints
    }

    func valueAtTime(x: Double) -> Double {
        let cp = controlPoints
        // Look for t value that corresponds to provided x
        let a = Double(-cp[0].x + 3 * cp[1].x - 3 * cp[2].x + cp[3].x)
        let b = Double(3 * cp[0].x - 6 * cp[1].x + 3 * cp[2].x)
        let c = Double(-3 * cp[0].x + 3 * cp[1].x)
        let d = Double(cp[0].x) - x
        let t = rootOfCubic(a: a, b, c, d, x)

        // Return corresponding y value
        let y = cubicFunctionValue(
            a: Double(-cp[0].y + 3 * cp[1].y - 3 * cp[2].y + cp[3].y),
            Double(3 * cp[0].y - 6 * cp[1].y + 3 * cp[2].y),
            Double(-3 * cp[0].y + 3 * cp[1].y),
            Double(cp[0].y),
            t
        )

        return y
    }

    private func rootOfCubic(a: Double, _ b: Double, _ c: Double, _ d: Double, _ startPoint: Double) -> Double {
        // We use 0 as start point as the root will be in the interval [0,1]
        var x = startPoint
        var lastX: Double = 1
        let kMaximumSteps = 10
        let kApproximationTolerance = 0.000_000_01

        // Approximate a root by using the Newton-Raphson method
        var y = 0
        while y <= kMaximumSteps, fabs(lastX - x) > kApproximationTolerance {
            lastX = x
            x = x - (cubicFunctionValue(a: a, b, c, d, x) / cubicDerivativeValue(a: a, b, c, d, x))
            y += 1
        }
        return x
    }

    private func cubicFunctionValue(a: Double, _ b: Double, _ c: Double, _ d: Double, _ x: Double) -> Double {
        (a * x * x * x) + (b * x * x) + (c * x) + d
    }

    private func cubicDerivativeValue(a: Double, _ b: Double, _ c: Double, _: Double, _ x: Double) -> Double {
        /// Derivation of the cubic (a*x*x*x)+(b*x*x)+(c*x)+d
        (3 * a * x * x) + (2 * b * x) + c
    }
}

extension UICollectionView: AnimatedScroll {
    var displayLink: CADisplayLink? {
        get { objc_getAssociatedObject(self, &displayLinkKey) as? CADisplayLink }

        set {
            objc_setAssociatedObject(
                self,
                &displayLinkKey,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
            )
        }
    }

    var duration: CFTimeInterval? {
        get { objc_getAssociatedObject(self, &durationKey) as? CFTimeInterval }

        set {
            objc_setAssociatedObject(
                self,
                &durationKey,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
            )
        }
    }

    var timingFunction: CAMediaTimingFunction? {
        get { objc_getAssociatedObject(self, &timingFunctionKey) as? CAMediaTimingFunction }

        set {
            objc_setAssociatedObject(
                self,
                &timingFunctionKey,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
            )
        }
    }

    var animationStarted: CADisplayLink? {
        get { objc_getAssociatedObject(self, &animationStartedKey) as? CADisplayLink }

        set {
            objc_setAssociatedObject(
                self,
                &animationStartedKey,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
            )
        }
    }

    var beginTime: CFTimeInterval {
        get { (objc_getAssociatedObject(self, &beginTimeKey) as? CFTimeInterval) ?? 0.0 }

        set {
            objc_setAssociatedObject(
                self,
                &beginTimeKey,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
            )
        }
    }

    var beginContentOffset: CGPoint? {
        get { (objc_getAssociatedObject(self, &beginContentOffsetKey) as? NSValue)?.cgPointValue }

        set {
            let val = NSValue(cgPoint: newValue!)
            objc_setAssociatedObject(
                self,
                &beginContentOffsetKey,
                val,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
            )
        }
    }

    var deltaContentOffset: CGPoint? {
        get { (objc_getAssociatedObject(self, &deltaContentOffsetKey) as? NSValue)?.cgPointValue }

        set {
            let val = NSValue(cgPoint: newValue!)
            objc_setAssociatedObject(
                self,
                &deltaContentOffsetKey,
                val,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN
            )
        }
    }

    public func setContentOffset(offset: CGPoint, timingFunction: CAMediaTimingFunction, duration: CFTimeInterval) {
        self.duration = duration
        self.timingFunction = timingFunction
        deltaContentOffset = CGPointMinus(p: offset, contentOffset)

        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(updateContentOffset))
            if #available(iOS 10, *) {
                displayLink!.preferredFramesPerSecond = 60
            } else {
                displayLink!.frameInterval = 1
            }
            displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
        } else {
            displayLink!.isPaused = false
        }
    }

    @objc func updateContentOffset(displayLink: CADisplayLink) {
        if beginTime == 0.0 {
            beginTime = displayLink.timestamp
            beginContentOffset = contentOffset
        } else {
            let deltaTime = displayLink.timestamp - beginTime

            let progress = CGFloat(deltaTime / duration!)
            if progress < 1.0 {
                let adjustedProgress = timingFunction!.valueAtTime(x: Double(progress))
                updateProgress(progress: CGFloat(adjustedProgress))
            } else {
                stopAnimation()
            }
        }
    }

    private func updateProgress(progress: CGFloat) {
        let currentDeltaContentOffset = CGPointScalarMult(s: progress, deltaContentOffset!)
        contentOffset = CGPointAdd(p: beginContentOffset!, currentDeltaContentOffset)
    }

    private func stopAnimation() {
        displayLink?.isPaused = true
        beginTime = 0.0

        contentOffset = CGPointAdd(p: beginContentOffset!, deltaContentOffset!)
        delegate?.scrollViewDidEndScrollingAnimation?(self)
    }
}
