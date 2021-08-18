import Flow
import Foundation
import UIKit
import hCore

extension EmbarkTextAction: ViewableAnimatorHandler {
  typealias Views = AnimatorViews
  typealias State = AnimatorState

  struct AnimatorViews {
    @ViewableAnimatedView var view: UIStackView
    @ViewableAnimatedView var box: UIView
    @ViewableAnimatedView var boxStack: UIStackView
    @ViewableAnimatedView var input: UIView
    @ViewableAnimatedView var button: UIButton
  }

  enum AnimatorState {
    case loading
    case notLoading
  }

  func animate(animator: ViewableAnimator<Self>) -> ReadSignal<Bool> {
    guard animator.state == .loading else { return ReadSignal(true) }

    let bag = DisposeBag()

    let view = animator.views.view
    let boxStack = animator.views.boxStack
    let box = animator.views.box
    let button = animator.views.button
    let input = animator.views.input

    input.endEditing(true)

    let dummyActivityIndicator = UIView()

    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.startAnimating()
    activityIndicator.alpha = 0

    func layoutAllContainers() {
      boxStack.layoutIfNeeded()
      view.layoutIfNeeded()
      box.layoutIfNeeded()
    }

    bag += Animated.now.animated(style: .easeOut(duration: 0.35)) {
      button.alpha = 0
      button.isHidden = true
      button.transform = CGAffineTransform(translationX: 0, y: 50)
      layoutAllContainers()
    }

    let inputAndLoader = Animated.now.animated(style: .lightBounce(duration: 0.25)) {
      input.alpha = 0
      layoutAllContainers()
    }

    bag +=
      inputAndLoader.atValue { _ in boxStack.addArrangedSubview(dummyActivityIndicator)
        boxStack.addSubview(activityIndicator)

        activityIndicator.snp.makeConstraints { make in make.center.equalTo(box.snp.center) }

        dummyActivityIndicator.snp.makeConstraints { make in
          make.width.height.equalTo(activityIndicator)
        }

        dummyActivityIndicator.layoutIfNeeded()
        activityIndicator.layoutIfNeeded()
      }
      .animated(style: .easeIn(duration: 0.25, delay: 0.20)) {
        activityIndicator.alpha = 1
        activityIndicator.layoutIfNeeded()
      }

    let completionSignal = inputAndLoader.animated(style: .lightBounce(duration: 0.5)) {
      input.isHidden = true
      boxStack.alignment = .center
      view.alignment = .center
      layoutAllContainers()
    }

    return completionSignal.hold(bag).boolean()
  }
}
