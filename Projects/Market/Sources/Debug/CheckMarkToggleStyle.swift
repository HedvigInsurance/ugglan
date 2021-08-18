import Foundation
import SwiftUI

@available(iOS 13, *) struct CheckmarkToggleStyle: ToggleStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    HStack {
      Button(action: { withAnimation { configuration.$isOn.wrappedValue.toggle() } }) {
        HStack {
          configuration.label.foregroundColor(.primary)
          Spacer()
          if configuration.isOn {
            Image(systemName: "checkmark").foregroundColor(.primary)
          }
        }
      }
    }
  }
}
