import Flow
import Foundation
import UIKit

class ActivityBarButton: SignalProvider {
  let position: BarButtonPosition
  let item: UIBarButtonItem
  let providedSignal: CoreSignal<Read, Void>

  private var navigationItem: UINavigationItem?
  private let activityIndicator = UIActivityIndicatorView()
  private let indicatorItem: UIBarButtonItem

  enum BarButtonPosition { case left, right }

  func attachTo(_ navigationItem: UINavigationItem) {
    self.navigationItem = navigationItem
    navigationItem.setRightBarButtonItems([item], animated: true)
  }

  func remove() {
    activityIndicator.stopAnimating()
    navigationItem?.setRightBarButtonItems([], animated: true)
  }

  func startAnimating() {
    navigationItem?.setRightBarButtonItems([indicatorItem], animated: true)

    activityIndicator.startAnimating()
    activityIndicator.color = .purple
    activityIndicator.sizeToFit()
  }

  func stopAnimating() {
    activityIndicator.stopAnimating()
    navigationItem?.setRightBarButtonItems([item], animated: true)
  }

  init(
    item: UIBarButtonItem,
    position: BarButtonPosition
  ) {
    providedSignal = item.providedSignal
    self.item = item
    self.position = position
    indicatorItem = UIBarButtonItem(customView: activityIndicator)
  }
}
