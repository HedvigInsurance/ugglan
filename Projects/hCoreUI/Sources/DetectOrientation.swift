import SwiftUI

struct DetectOrientation: ViewModifier {
    @Binding var orientation: UIDeviceOrientation

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                orientation = UIDevice.current.orientation
            }
    }
}

extension View {
    public func detectOrientation(_ orientation: Binding<UIDeviceOrientation>) -> some View {
        modifier(DetectOrientation(orientation: orientation))
    }
}
