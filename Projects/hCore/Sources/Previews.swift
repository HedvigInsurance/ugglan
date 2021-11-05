import SwiftUI

struct ScreenPreview<Screen: View>: View {
    var screen: Screen

    let colorScheme: ColorScheme

    var body: some View {
        ForEach(devices) { device in
            NavigationView {
                self.screen
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
            }
            .previewDevice(PreviewDevice(rawValue: device.name))
            .colorScheme(colorScheme)
            .previewDisplayName("\(colorScheme): \(device)")
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    struct Device: Identifiable {
        let name: String
        let id = UUID()
    }

    private var devices: [Device] {
        deviceNames.map {
            .init(name: $0)
        }
    }

    private var deviceNames: [String] {
        [
            "iPhone 12"
        ]
    }
}

struct ComponentPreview<Component: View>: View {
    var component: Component

    let colorScheme: ColorScheme
    let contentSizeCategory: ContentSizeCategory

    var body: some View {
        self.component
            .previewLayout(.sizeThatFits)
            .background(Color(UIColor.systemBackground))
            .colorScheme(colorScheme)
            .environment(\.sizeCategory, contentSizeCategory)
            .previewDisplayName(
                "\(colorScheme) + \(contentSizeCategory)"
            )
    }
}

extension View {
    public func previewAsScreen(colorScheme: ColorScheme = .light) -> some View {
        ScreenPreview(screen: self, colorScheme: colorScheme)
    }

    public func previewAsComponent(colorScheme: ColorScheme = .light, size: ContentSizeCategory = .large) -> some View {
        ComponentPreview(component: self, colorScheme: colorScheme, contentSizeCategory: size)
    }
}
