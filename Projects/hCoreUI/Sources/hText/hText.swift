import Foundation
import SwiftUI
import UIKit

private struct EnvironmentDefaultHTextStyle: EnvironmentKey {
  static let defaultValue: UIFont.TextStyle? = nil
}

extension EnvironmentValues {
  public var defaultHTextStyle: UIFont.TextStyle? {
    get { self[EnvironmentDefaultHTextStyle.self] }
    set { self[EnvironmentDefaultHTextStyle.self] = newValue }
  }
}

extension String {
  public func hText(_ style: UIFont.TextStyle? = nil) -> hText {
    if let style = style {
      return hCoreUI.hText(self, style: style)
    } else {
      return hCoreUI.hText(self)
    }
  }
}

public struct hText: View {
  public var text: String
  public var style: UIFont.TextStyle?
  @Environment(\.defaultHTextStyle) var defaultStyle

  public init(
    _ text: String,
    style: UIFont.TextStyle
  ) {
    self.text = text
    self.style = style
  }

  public init(
    _ text: String
  ) {
    self.text = text
    self.style = nil
  }

  public var body: some View {
    Text(text)
      .font(Font(Fonts.fontFor(style: style ?? defaultStyle ?? .body)))
  }
}
